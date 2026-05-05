import pandas as pd
import numpy as np
import re
from pathlib import Path

RAW       = Path("data/raw")
PROCESSED = Path("data/processed")
PROCESSED.mkdir(parents=True, exist_ok=True)

print("Loading postings.csv (493MB — takes ~30s)...")
df = pd.read_csv(RAW / "postings.csv", low_memory=False)
print(f"Loaded {len(df):,} rows")

# 1. Droping useless columns 
drop_cols = ["job_posting_url","application_url","application_type",
             "posting_domain","sponsored","expiry","closed_time",
             "zip_code","fips","views","applies"]
df.drop(columns=[c for c in drop_cols if c in df.columns], inplace=True)

# 2. Parse dates 
# listed_time is Unix ms timestamp
df["posted_date"] = pd.to_datetime(df["listed_time"], unit="ms", errors="coerce")
df = df.dropna(subset=["posted_date"])
df["post_year"]    = df["posted_date"].dt.year
df["post_quarter"] = df["posted_date"].dt.to_period("Q").astype(str)
df["post_month"]   = df["posted_date"].dt.to_period("M").astype(str)

# Keep only 2022–2025
df = df[df["post_year"].between(2022, 2025)]
print(f"After date filter: {len(df):,} rows")

# 3. Salary — use normalized_salary (already in USD annually) 
df["salary_mid"] = pd.to_numeric(df["normalized_salary"], errors="coerce")

# Drop extreme outliers
df.loc[df["salary_mid"] < 20_000,  "salary_mid"] = np.nan
df.loc[df["salary_mid"] > 600_000, "salary_mid"] = np.nan

# min/max from raw columns
df["salary_min"] = pd.to_numeric(df["min_salary"], errors="coerce")
df["salary_max"] = pd.to_numeric(df["max_salary"], errors="coerce")

# 4. Location → city, state 
def split_loc(loc):
    if pd.isna(loc):
        return None, None
    parts = str(loc).split(",")
    city  = parts[0].strip() if len(parts) >= 1 else None
    state = parts[1].strip() if len(parts) >= 2 else None
    return city, state

df[["city","state"]] = df["location"].apply(lambda x: pd.Series(split_loc(x)))

# 5. Remote flag 
df["remote_ratio"] = df["remote_allowed"].map({1.0: 100, 0.0: 0, True: 100, False: 0})
df["remote_ratio"]  = pd.to_numeric(df["remote_ratio"], errors="coerce").fillna(0).astype(int)

# 6. Experience level 
exp_map = {
    "Entry level"   : "Entry",
    "Mid-Senior level": "Mid-Senior",
    "Associate"     : "Associate",
    "Director"      : "Director",
    "Executive"     : "Executive",
    "Internship"    : "Internship",
    "Not Applicable": "Other",
}
df["experience_level"] = df["formatted_experience_level"].map(exp_map).fillna("Unknown")

# 7. Role family classification 
ROLE_MAP = [
    ("llm",            "AI/LLM Engineer"),
    ("prompt engineer","AI/LLM Engineer"),
    ("ai engineer",    "AI/LLM Engineer"),
    ("generative ai",  "AI/LLM Engineer"),
    ("machine learning","ML Engineer"),
    ("ml engineer",    "ML Engineer"),
    ("data scientist", "Data Scientist"),
    ("data engineer",  "Data Engineer"),
    ("data analyst",   "Data Analyst"),
    ("business analyst","Business Analyst"),
    ("analytics engineer","Analytics Engineer"),
    ("backend",        "Backend Engineer"),
    ("software engineer","Software Engineer"),
    ("software developer","Software Engineer"),
    ("frontend",       "Frontend Engineer"),
    ("full stack",     "Full Stack Engineer"),
    ("fullstack",      "Full Stack Engineer"),
    ("devops",         "DevOps/SRE"),
    ("site reliability","DevOps/SRE"),
    ("platform engineer","DevOps/SRE"),
    ("cloud engineer", "Cloud/Infra Engineer"),
    ("infrastructure", "Cloud/Infra Engineer"),
    ("security engineer","Security Engineer"),
    ("product manager","Product Manager"),
    ("product analyst","Product Analyst"),
]

def classify_role(title):
    if pd.isna(title):
        return "Other"
    t = str(title).lower()
    for kw, family in ROLE_MAP:
        if kw in t:
            return family
    return "Other"

df["role_family"] = df["title"].apply(classify_role)
print("Role family distribution:")
print(df["role_family"].value_counts().head(15).to_string())

# 8. Era column 
df["era"] = df["posted_date"].apply(
    lambda d: "Post-ChatGPT" if d >= pd.Timestamp("2022-11-30") else "Pre-ChatGPT"
)

# 9. Rename for consistency 
df.rename(columns={
    "company_name"              : "company",
    "formatted_experience_level": "exp_level_raw",
    "formatted_work_type"       : "employment_type",
    "skills_desc"               : "skills_text",
}, inplace=True)

# 10. Save 
out_cols = [
    "job_id","title","company","location","city","state",
    "posted_date","post_year","post_quarter","post_month",
    "role_family","experience_level","employment_type",
    "remote_ratio","salary_min","salary_max","salary_mid",
    "era","description","skills_text","company_id"
]
df[[c for c in out_cols if c in df.columns]].to_csv(
    PROCESSED / "job_postings_clean.csv", index=False
)
print(f"\nSaved job_postings_clean.csv — {len(df):,} rows")
print(f"Salary coverage: {df['salary_mid'].notna().sum():,} rows ({df['salary_mid'].notna().mean()*100:.1f}%)")
