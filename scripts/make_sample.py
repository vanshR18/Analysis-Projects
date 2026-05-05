import pandas as pd
from pathlib import Path

Path('data/sample').mkdir(parents=True, exist_ok=True)

pd.read_csv('data/processed/job_postings_with_skills.csv', nrows=1000)\
  .to_csv('data/sample/postings_sample.csv', index=False)

pd.read_csv('data/raw/job_skills.csv', nrows=1000)\
  .to_csv('data/sample/job_skills_sample.csv', index=False)

pd.read_csv('data/raw/layoffs.csv', nrows=1000)\
  .to_csv('data/sample/layoffs_sample.csv', index=False)

pd.read_csv('data/raw/ds_salaries.csv')\
  .to_csv('data/sample/ds_salaries_sample.csv', index=False)

print("Done.")