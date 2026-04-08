"""
Script 03 — Clean salary benchmarks and layoffs
"""
import pandas as pd
import numpy as np
from pathlib import Path

RAW       = Path("data/raw")
PROCESSED = Path("data/processed")

# ── 1. ds_salaries.csv → salary_benchmarks_clean.csv ─────────────────────────
print("Cleaning ds_salaries.csv...")
sal = pd.read_csv(RAW / "ds_salaries.csv")

# columns: work_year, experience_level, employment_type, job_title,
#          salary, salary_currency, salary_in_usd,
#          employee_residence, remote_ratio, company_location, company_size

sal = sal.rename(columns={
    "work_year"          : "year",
    "salary_in_usd"      : "salary_usd",
    "job_title"          : "job_title",
})

# Role family mapping
ROLE_MAP = [
    ("llm",              "AI/LLM Engineer"),
    ("machine learning", "ML Engineer"),
    ("data scientist",   "Data Scientist"),
    ("data engineer",    "Data Engineer"),
    ("data analyst",     "Data Analyst"),
    ("analytics",        "Analytics Engineer"),
    ("business analyst", "Business Analyst"),
    ("research",         "ML/Research Scientist"),
]
def classify(title):
    t = str(title).lower()
    for kw, fam in ROLE_MAP:
        if kw in t:
            return fam
    return "Other"

sal["role_family"]  = sal["job_title"].apply(classify)
sal["work_mode"]    = sal["remote_ratio"].map({0:"On-site",50:"Hybrid",100:"Remote"})

# Filter realistic salaries
sal = sal[(sal["salary_usd"] >= 30_000) & (sal["salary_usd"] <= 500_000)]

sal.to_csv(PROCESSED / "salary_benchmarks_clean.csv", index=False)
print(f"Saved salary_benchmarks_clean.csv — {len(sal):,} rows")
print(sal[["year","role_family","salary_usd","work_mode"]].head(3).to_string(index=False))

# ── 2. layoffs.csv → layoffs_clean.csv ───────────────────────────────────────
print("\nCleaning layoffs.csv...")
lay = pd.read_csv(RAW / "layoffs.csv")

# columns: company, location, total_laid_off, date, percentage_laid_off,
#          industry, source, stage, funds_raised, country, date_added

lay = lay.rename(columns={
    "total_laid_off"      : "headcount_lost",
    "date"                : "date_announced",
    "percentage_laid_off" : "percentage_laid",
})

lay["date_announced"] = pd.to_datetime(lay["date_announced"], errors="coerce")
lay["headcount_lost"] = pd.to_numeric(lay["headcount_lost"], errors="coerce")
lay["percentage_laid"]= pd.to_numeric(lay["percentage_laid"], errors="coerce")

# Drop rows with no date or headcount
lay = lay.dropna(subset=["date_announced"])
lay["headcount_lost"] = lay["headcount_lost"].fillna(0).astype(int)

lay.to_csv(PROCESSED / "layoffs_clean.csv", index=False)
print(f"Saved layoffs_clean.csv — {len(lay):,} rows")
print(f"Date range: {lay['date_announced'].min().date()} → {lay['date_announced'].max().date()}")
print(f"Total headcount lost: {lay['headcount_lost'].sum():,.0f}")

print("\nAll cleaning done. Processed files:")
for f in PROCESSED.iterdir():
    size = f.stat().st_size / 1024**2
    print(f"  {f.name:<45} {size:.1f} MB")