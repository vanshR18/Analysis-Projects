"""
Script 02 — Build job_postings_with_skills.csv

The LinkedIn dataset already has job_skills.csv (job_id + skill_abr)
and skills.csv (skill_abr + skill_name), so we JOIN them instead of
regex-parsing descriptions. Much cleaner and more accurate.
"""
import pandas as pd
from pathlib import Path

RAW       = Path("data/raw")
PROCESSED = Path("data/processed")

print("Loading files...")
postings  = pd.read_csv(PROCESSED / "job_postings_clean.csv", low_memory=False)
job_skills = pd.read_csv(RAW / "job_skills.csv")          # job_id, skill_abr
skills_ref = pd.read_csv(RAW / "skills.csv")              # skill_abr, skill_name

print(f"Postings  : {len(postings):,}")
print(f"Job-skills: {len(job_skills):,}")
print(f"Skills ref: {len(skills_ref):,}")

# ── 1. Merge skill_abr → skill_name ──────────────────────────────────────────
job_skills = job_skills.merge(skills_ref, on="skill_abr", how="left")

# ── 2. Normalise skill names → lowercase for consistency ─────────────────────
job_skills["skill_name"] = job_skills["skill_name"].str.strip().str.lower()

# ── 3. Aggregate skills per job_id into comma-separated string ───────────────
skills_agg = (job_skills.groupby("job_id")["skill_name"]
              .apply(lambda x: ",".join(x.dropna().unique()))
              .reset_index()
              .rename(columns={"skill_name": "raw_skills"}))

print(f"Jobs with skill data: {len(skills_agg):,}")

# ── 4. Merge back onto postings ───────────────────────────────────────────────
df = postings.merge(skills_agg, on="job_id", how="left")
coverage = df["raw_skills"].notna().mean() * 100
print(f"Skill coverage: {coverage:.1f}% of postings")

# ── 5. Also flag AI/LLM skills from description for jobs missing skill tags ──
AI_KEYWORDS = [
    "langchain","openai","llm","large language model","rag",
    "vector database","huggingface","fine-tuning","prompt engineering",
    "gpt","gemini","claude","llama","mistral"
]

def extract_ai_skills(row):
    existing = str(row.get("raw_skills", "") or "")
    desc     = str(row.get("description", "") or "").lower()
    found    = [kw for kw in AI_KEYWORDS if kw in desc]
    if found:
        all_skills = set(existing.split(",")) | set(found)
        return ",".join(s for s in all_skills if s)
    return existing if existing else None

df["raw_skills"] = df.apply(extract_ai_skills, axis=1)

# ── 6. Save ───────────────────────────────────────────────────────────────────
df.to_csv(PROCESSED / "job_postings_with_skills.csv", index=False)
print(f"\nSaved job_postings_with_skills.csv — {len(df):,} rows")

# ── 7. Also save the long-format skill table for SQL/Power BI ─────────────────
skills_long = (
    df[["job_id","post_year","post_quarter","role_family","era","raw_skills"]]
    .dropna(subset=["raw_skills"])
    .assign(skill=lambda d: d["raw_skills"].str.split(","))
    .explode("skill")
)
skills_long["skill"] = skills_long["skill"].str.strip()
skills_long = skills_long[skills_long["skill"] != ""]
skills_long.to_csv(PROCESSED / "skills_long.csv", index=False)
print(f"Saved skills_long.csv — {len(skills_long):,} skill-posting pairs")
print(f"Unique skills: {skills_long['skill'].nunique()}")