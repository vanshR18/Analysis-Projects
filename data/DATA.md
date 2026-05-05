# Data Documentation

This file documents every dataset used in the **Developer Job Market Shift Analyzer** project — where to get it, what it contains, how it was cleaned, and how it connects to the rest of the pipeline.

---

## Why raw data is not in this repository

The combined raw dataset size is ~800MB, which exceeds GitHub's file size limits and would make cloning impractical. All datasets are **free and publicly available**. This file gives you everything you need to reproduce the exact same `data/raw/` folder used to build this project.

---

## Quick reference

| File | Source | Size | Used in |
|---|---|---|---|
| `postings.csv` | Kaggle — LinkedIn Job Postings | 493 MB | Primary fact table |
| `job_skills.csv` | Kaggle — LinkedIn Job Postings | 3.4 MB | Skill bridge table |
| `skills.csv` | Kaggle — LinkedIn Job Postings | 679 B | Skill name lookup |
| `companies.csv` | Kaggle — LinkedIn Job Postings | 23 MB | Company metadata |
| `salaries.csv` | Kaggle — LinkedIn Job Postings | 2.2 MB | LinkedIn salary ranges |
| `ds_salaries.csv` | Kaggle — Data Science Salaries | 37 KB | Salary benchmarks |
| `layoffs.csv` | Kaggle — Tech Layoffs 2022–2024 | 742 KB | Layoff events |
| `LCA_Disclosure_Data_FY2025_Q1.xlsx` | DOL — H-1B LCA Program | 84 MB | US salary enrichment |
| `LCA_Disclosure_Data_FY2025_Q2.xlsx` | DOL — H-1B LCA Program | 102 MB | US salary enrichment |
| `LCA_Disclosure_Data_FY2025_Q4.xlsx` | DOL — H-1B LCA Program | 76 MB | US salary enrichment |

---

## Dataset 1 — LinkedIn Job Postings

**Source:** [kaggle.com/datasets/arshkon/linkedin-job-postings](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings)
**License:** CC0 Public Domain

### Download

```bash
kaggle datasets download arshkon/linkedin-job-postings -p data/raw/ --unzip
```

### Files included

#### `postings.csv` — 493 MB — Primary fact table

| Column | Type | Description |
|---|---|---|
| `job_id` | int | Unique posting identifier |
| `company_name` | str | Hiring company name |
| `title` | str | Job title as posted |
| `description` | str | Full job description text |
| `max_salary` | float | Maximum salary (raw, various pay periods) |
| `med_salary` | float | Median salary (raw) |
| `min_salary` | float | Minimum salary (raw) |
| `normalized_salary` | float | Annual USD salary (pre-normalized by Kaggle) |
| `pay_period` | str | HOURLY / MONTHLY / YEARLY |
| `currency` | str | Salary currency code |
| `compensation_type` | str | BASE\_SALARY / TOTAL\_COMP etc. |
| `location` | str | "City, State" string |
| `zip_code` | str | US zip code |
| `remote_allowed` | float | 1.0 = remote allowed, 0.0 = not |
| `formatted_work_type` | str | Full-time / Part-time / Contract |
| `formatted_experience_level` | str | Entry level / Mid-Senior level etc. |
| `listed_time` | int | Unix timestamp in milliseconds |
| `original_listed_time` | int | Original listing Unix timestamp |
| `expiry` | int | Expiry Unix timestamp |
| `skills_desc` | str | Freetext skills mentioned in posting |
| `company_id` | int | FK to companies.csv |
| `applies` | int | Number of applicants |
| `views` | int | Number of views |

**Key cleaning steps applied in `01_clean_raw_data.py`:**
- `listed_time` parsed from Unix ms → datetime
- `normalized_salary` used as the canonical salary field; values outside $20K–$600K dropped as outliers
- `location` split into `city` and `state` on the first comma
- `remote_allowed` mapped to `remote_ratio` (1.0 → 100, 0.0 → 0)
- `formatted_experience_level` standardised to short labels (Entry, Mid-Senior, Director, etc.)
- Custom role family classifier applied to `title` → `role_family` column

#### `job_skills.csv` — 3.4 MB — Skill bridge table

| Column | Type | Description |
|---|---|---|
| `job_id` | int | FK to postings.csv |
| `skill_abr` | str | Abbreviated skill code (e.g. PYTH, SQL) |

Used in `02_extract_skills.py` — joined with `skills.csv` to resolve abbreviations into readable names, then aggregated per `job_id` into a comma-separated `raw_skills` column.

#### `skills.csv` — 679 B — Skill name lookup

| Column | Type | Description |
|---|---|---|
| `skill_abr` | str | Abbreviation code |
| `skill_name` | str | Human-readable skill name |

#### `companies.csv` — 23 MB — Company metadata

| Column | Type | Description |
|---|---|---|
| `company_id` | int | PK |
| `name` | str | Company name |
| `description` | str | Company description |
| `company_size` | int | Headcount bucket (1=1–10 … 7=10001+) |
| `state` | str | US state |
| `country` | str | Country code |
| `url` | str | Company website |
| `follower_count` | int | LinkedIn followers |

Used optionally to enrich postings with company size.

#### `salaries.csv` — 2.2 MB — LinkedIn salary ranges

| Column | Type | Description |
|---|---|---|
| `salary_id` | int | PK |
| `job_id` | int | FK to postings.csv |
| `max_salary` | float | Max salary for this posting |
| `med_salary` | float | Median salary |
| `min_salary` | float | Min salary |
| `pay_period` | str | HOURLY / MONTHLY / YEARLY |
| `currency` | str | Currency code |
| `compensation_type` | str | BASE\_SALARY / TOTAL\_COMP |

More granular salary data than what is in `postings.csv` directly. Cross-referenced during salary analysis.

---

## Dataset 2 — Data Science Job Salaries

**Source:** [kaggle.com/datasets/ruchi798/data-science-job-salaries](https://www.kaggle.com/datasets/ruchi798/data-science-job-salaries)
**License:** CC0 Public Domain

### Download

```bash
kaggle datasets download ruchi798/data-science-job-salaries -p data/raw/ --unzip
```

### File: `ds_salaries.csv` — 37 KB

| Column | Type | Description |
|---|---|---|
| `work_year` | int | Year salary was paid (2020–2023) |
| `experience_level` | str | EN=Entry / MI=Mid / SE=Senior / EX=Executive |
| `employment_type` | str | FT / PT / CT / FL |
| `job_title` | str | Job title |
| `salary` | int | Salary in original currency |
| `salary_currency` | str | ISO currency code |
| `salary_in_usd` | int | Salary converted to USD |
| `employee_residence` | str | ISO country code of employee |
| `remote_ratio` | int | 0=On-site / 50=Hybrid / 100=Remote |
| `company_location` | str | ISO country code of company |
| `company_size` | str | S=Small / M=Medium / L=Large |

**Key cleaning steps applied in `03_clean_salary_layoffs.py`:**
- `salary_in_usd` used as the canonical salary field
- Values outside $30K–$500K dropped
- `remote_ratio` mapped to `work_mode` (0→On-site, 50→Hybrid, 100→Remote)
- Custom role family classifier applied to `job_title`

**Used as:** salary benchmark table for median/percentile analysis by role, experience level, and work mode. Supplements the sparse salary data in `postings.csv`.

---

## Dataset 3 — Tech Layoffs 2022–2024

**Source:** [kaggle.com/datasets/swaptr/layoffs-2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
**License:** CC0 Public Domain

### Download

```bash
kaggle datasets download swaptr/layoffs-2022 -p data/raw/ --unzip
```

### File: `layoffs.csv` — 742 KB

| Column | Type | Description |
|---|---|---|
| `company` | str | Company name |
| `location` | str | Office city |
| `total_laid_off` | float | Headcount lost (nullable) |
| `date` | str | Announcement date (YYYY-MM-DD) |
| `percentage_laid_off` | float | % of workforce laid off (nullable) |
| `industry` | str | Industry sector |
| `source` | str | News source URL |
| `stage` | str | Funding stage (Series A, IPO, etc.) |
| `funds_raised` | float | Total funds raised (millions USD) |
| `country` | str | Country |
| `date_added` | str | Date record was added to dataset |

**Key cleaning steps applied in `03_clean_salary_layoffs.py`:**
- `date` parsed to datetime, rows with no date dropped
- `total_laid_off` renamed to `headcount_lost`, nulls filled with 0
- `percentage_laid_off` converted to numeric

**Used as:** layoff events table. Joined against `job_postings` on company name (lowercased) to measure whether companies that laid off continued posting jobs afterward.

**Caveat:** Data is crowd-sourced from public news reports. Some events may be missing or have approximate headcount figures.

---

## Dataset 4 — H-1B LCA Salary Disclosures (DOL)

**Source:** [dol.gov → ETA → Foreign Labor → Performance Data](https://www.dol.gov/agencies/eta/foreign-labor/performance)
**License:** US Government Open Data (public domain)

### Download

1. Go to the link above
2. Scroll to **"LCA Programs (H-1B, H-1B1, E-3)"**
3. Download the Excel files for FY2025 Q1, Q2, and Q4
4. Place them in `data/raw/` — filenames should match exactly:

```
LCA_Disclosure_Data_FY2025_Q1.xlsx   (84 MB)
LCA_Disclosure_Data_FY2025_Q2.xlsx   (102 MB)
LCA_Disclosure_Data_FY2025_Q4.xlsx   (76 MB)
```

### Key columns

| Column | Description |
|---|---|
| `JOB_TITLE` | Employer-submitted job title |
| `PREVAILING_WAGE` | Wage the employer certified to pay |
| `WAGE_RATE_OF_PAY_FROM` | Minimum wage offered |
| `WAGE_RATE_OF_PAY_TO` | Maximum wage offered |
| `WAGE_UNIT_OF_PAY` | Year / Hour / Month |
| `EMPLOYER_NAME` | Company name |
| `WORKSITE_CITY` | City of employment |
| `WORKSITE_STATE` | State of employment |
| `SOC_TITLE` | Standard Occupational Classification title |
| `CASE_STATUS` | Certified / Denied / Withdrawn |

**Used as:** ground-truth salary enrichment for US tech roles. Because employers submit these wages under legal obligation, they are more reliable than self-reported or scraped salary data.

**Note:** Only `CASE_STATUS = Certified` rows are used in analysis.

---

## Data flow

```
data/raw/                          data/processed/
─────────────────────────────      ────────────────────────────────────
postings.csv          ──┐
                        ├──► 01_clean_raw_data.py ──► job_postings_clean.csv
companies.csv         ──┘
                                                            │
job_skills.csv        ──┐                                   │
                        ├──► 02_extract_skills.py ──► job_postings_with_skills.csv
skills.csv            ──┘                             skills_long.csv

ds_salaries.csv       ──┐
                        ├──► 03_clean_salary_layoffs.py ──► salary_benchmarks_clean.csv
layoffs.csv           ──┘                                   layoffs_clean.csv

                              data/processed/ ──► eda.ipynb ──► data/exports/
                              data/processed/ ──► sql/ ──► PostgreSQL ──► Power BI
```

---

## Processed files reference

These files are generated by the cleaning scripts and are also not committed (too large). They are the inputs to `eda.ipynb` and the SQL load scripts.

| File | Rows | Size (approx) | Description |
|---|---|---|---|
| `job_postings_clean.csv` | ~123K | ~180 MB | Cleaned postings with role family, parsed dates, salary_mid |
| `job_postings_with_skills.csv` | ~123K | ~190 MB | Above + `raw_skills` column (comma-separated skill names) |
| `skills_long.csv` | ~900K+ | ~50 MB | One row per job-skill pair — used for all skill frequency analysis |
| `salary_benchmarks_clean.csv` | ~3.5K | ~400 KB | Cleaned ds_salaries with role_family and work_mode columns |
| `layoffs_clean.csv` | ~2.3K | ~300 KB | Cleaned layoffs with parsed dates and numeric headcount |

---

## Sample data

A 1000-row sample of key files is committed in `data/sample/` so the notebook can be explored without downloading the full datasets.

To use the sample, change the `PROCESSED` path in `eda.ipynb` cell 2:

```python
PROCESSED = Path("data/sample")   # instead of Path("data/processed")
```

Generate fresh samples after running the pipeline:

```bash
python -c "
import pandas as pd
from pathlib import Path

Path('data/sample').mkdir(exist_ok=True)
pd.read_csv('data/processed/job_postings_with_skills.csv', nrows=1000).to_csv('data/sample/postings_sample.csv', index=False)
pd.read_csv('data/raw/job_skills.csv', nrows=1000).to_csv('data/sample/job_skills_sample.csv', index=False)
pd.read_csv('data/raw/layoffs.csv', nrows=1000).to_csv('data/sample/layoffs_sample.csv', index=False)
print('Sample files written to data/sample/')
"
```
