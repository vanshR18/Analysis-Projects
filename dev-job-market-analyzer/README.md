# Developer Job Market Shift Analyzer

> A data analytics project exploring how the tech hiring landscape shifted across 123,000+ job postings — examining role demand, skill trends, salary patterns, and remote work distribution.

---

## Overview

This project analyzes LinkedIn developer job postings from 2024 alongside historical tech layoff data and salary benchmarks to surface actionable insights about the current state of the developer job market.

Built entirely with Python, PostgreSQL, and Power BI — no machine learning, pure analytics.

---

## Key Questions Answered

- Which developer roles are most in demand right now?
- Which skills command the highest salary premium?
- How did skill demand shift between Q1 and Q2 2024?
- Do remote jobs still pay more than on-site roles?
- Which companies laid off staff but continued hiring afterward?
- Which cities have the highest concentration of tech postings?

---

## Key Findings

| Finding | Value |
|---|---|
| Total postings analyzed | 123,849 |
| Unique companies hiring | ~18,000+ |
| Most in-demand role | Software Engineer |
| AI/LLM Engineer share | ~0.2% of all postings |
| Remote job share | 12.3% |
| Skill coverage | 99% of postings |
| Date range | Mar 24 – Apr 20, 2024 |

---

## Project Structure

```
dev-job-market-analyzer/
├── data/
│   ├── raw/                        # Downloaded source files (not committed)
│   │   ├── postings.csv            # LinkedIn job postings (493MB)
│   │   ├── job_skills.csv          # Skill tags per job ID
│   │   ├── skills.csv              # Skill abbreviation → name mapping
│   │   ├── companies.csv           # Company metadata
│   │   ├── salaries.csv            # LinkedIn salary ranges
│   │   ├── ds_salaries.csv         # Data science salary benchmarks
│   │   ├── layoffs.csv             # Tech layoff events 2022–2024
│   │   └── LCA_Disclosure_*.xlsx   # H-1B DOL salary disclosures
│   ├── processed/                  # Cleaned CSVs (output of scripts)
│   └── exports/                    # Power BI ready CSVs + chart PNGs
├── scripts/
│   ├── 01_clean_raw_data.py        # Clean postings, parse dates, classify roles
│   ├── 02_extract_skills.py        # Join skill tags, build skills_long.csv
│   └── 03_clean_salary_layoffs.py  # Clean salary benchmarks and layoffs
├── sql/
│   ├── 01_schema.sql               # PostgreSQL table definitions + indexes
│   ├── 02_clean_and_load.sql       # Load processed CSVs into Postgres
│   ├── 03_skill_demand.sql         # Skill frequency and YoY trend queries
│   ├── 04_salary_analysis.sql      # Salary by role, skill premium, remote delta
│   ├── 05_location_trends.sql      # City-level posting distribution
│   ├── 06_role_family_shifts.sql   # Role family demand shifts
│   └── 07_powerbi_views.sql        # Pre-aggregated views for Power BI
├── notebooks/
│   └── eda.ipynb                   # Full exploratory analysis (17 charts)
├── powerbi/
│   └── job_market_analyzer.pbix    # Power BI report (5 pages)
├── requirements.txt
└── README.md
```

---

## Datasets

| Dataset | Source | Size | Description |
|---|---|---|---|
| LinkedIn Job Postings | [Kaggle — arshkon](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings) | 493 MB | 123K+ postings with title, company, location, salary, skills |
| Data Science Salaries | [Kaggle — ruchi798](https://www.kaggle.com/datasets/ruchi798/data-science-job-salaries) | 37 KB | Salary benchmarks by role, year, experience, remote ratio |
| Tech Layoffs 2022–2024 | [Kaggle — swaptr](https://www.kaggle.com/datasets/swaptr/layoffs-2022) | 742 KB | Company-level layoff events with headcount and industry |
| H-1B Salary Disclosures | [DOL LCA Program](https://www.dol.gov/agencies/eta/foreign-labor/performance) | ~250 MB | Employer-submitted salary ranges for US tech visa roles |

All datasets are publicly available. Raw files are not committed to this repository due to size. See **Setup** below to download them.

---

## Setup

### Prerequisites

- Python 3.10+
- PostgreSQL 14+
- Power BI Desktop (Windows) or use the exported CSVs with any BI tool

### Install dependencies

```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Download data

```bash
pip install kaggle

# Place kaggle.json in ~/.kaggle/ first (from kaggle.com → Settings → API)
kaggle datasets download arshkon/linkedin-job-postings -p data/raw/ --unzip
kaggle datasets download swaptr/layoffs-2022          -p data/raw/ --unzip
kaggle datasets download ruchi798/data-science-job-salaries -p data/raw/ --unzip
```

Download H-1B LCA files manually from the DOL link above and place in `data/raw/`.

### Run cleaning pipeline

Always run from the project root directory:

```bash
cd dev-job-market-analyzer

python scripts/01_clean_raw_data.py        # ~2–3 min (493MB)
python scripts/02_extract_skills.py        # ~1 min
python scripts/03_clean_salary_layoffs.py  # ~30 sec
```

After completion, `data/processed/` will contain:

```
job_postings_clean.csv
job_postings_with_skills.csv
skills_long.csv
salary_benchmarks_clean.csv
layoffs_clean.csv
```

### Run the notebook

```bash
jupyter notebook notebooks/eda.ipynb
```

Run all cells top-to-bottom. Charts export automatically to `data/exports/`.

### Load into PostgreSQL

```bash
psql -U postgres -c "CREATE DATABASE job_market;"
psql -U postgres -d job_market -f sql/01_schema.sql
```

Then run `scripts/04_load_to_postgres.py` (update credentials in the script first).

---

## EDA Notebook — Chart Index

| # | Chart | Description |
|---|---|---|
| 01 | Weekly posting volume | Posting activity over the 4-week window |
| 02 | Role family Q1 vs Q2 | Grouped bar comparing role demand across quarters |
| 03 | Top 20 skills overall | Most mentioned skills across all postings |
| 04 | Skill demand Q1→Q2 shift | Fastest rising and falling skills |
| 05 | Skill share shift | Percentage point change in skill share |
| 06 | Top 15 skills by quarter | Side-by-side Q1 vs Q2 skill comparison |
| 07 | Salary by role (box plot) | P25 / median / P75 distribution per role family |
| 08 | Salary Q1 vs Q2 | Median salary change across quarters |
| 09 | Skill salary premium | Which skills add the most to compensation |
| 10 | Remote vs on-site salary | Median salary by work mode |
| 11 | Top 15 hiring cities | Cities by total posting volume |
| 12 | City share Q1→Q2 | Which cities gained or lost posting share |
| 13 | Role volume Q1→Q2 | Absolute change in postings per role |
| 14 | AI/LLM Engineer by quarter | Bar chart with Q1→Q2 % change annotation |
| 15 | Python skill co-occurrence | Skills most listed alongside Python |
| 16 | Layoffs timeline | Monthly headcount lost across 2022–2024 |
| 17 | Layoffs vs rehiring | Companies that laid off vs subsequent job postings |

---

## Power BI Report — Pages

| Page | Description |
|---|---|
| Market Overview | KPI cards, posting volume, top roles, remote share |
| Skill Demand | Skill treemap, Q1→Q2 shift, category breakdown |
| Salary Intelligence | Role salary bands, skill premium chart, remote delta |
| Location Map | City posting heatmap, top 15 cities, salary scatter |
| Role Deep Dive | AI/LLM trends, Python co-occurrence, role shift bars |

---

## Tech Stack

| Layer | Tools |
|---|---|
| Data cleaning | Python, Pandas, NumPy |
| Database | PostgreSQL 14 (CTEs, window functions, percentile aggregates) |
| Exploration | Jupyter, Matplotlib, Seaborn |
| Visualization | Power BI Desktop |
| Environment | Python 3.12, venv |

---

## SQL Highlights

The SQL layer covers:

- **Window functions** — rolling skill demand rank per quarter, salary percentile bands
- **Cohort queries** — role family market share over time
- **Skill co-occurrence** — bridge table join to find skills appearing in the same JD
- **Layoff impact** — companies that laid off matched against subsequent postings via fuzzy company name join
- **Pre-aggregated views** — 5 Power BI views for fast DirectQuery performance

---

## Limitations

- Dataset covers only ~4 weeks (Mar–Apr 2024), so quarter-over-quarter trends are indicative rather than definitive
- Salary data is sparse (~12% coverage in LinkedIn postings); salary insights use the separate ds_salaries benchmark dataset
- Role classification uses keyword matching on job titles — roles with non-standard titles fall into "Other" (~87% of raw postings before classifier tuning)
- Layoff data is sourced from public news reports and may not be exhaustive

---

## Author

**Rohit Pal**
B.Tech CSE, IET Lucknow (Batch 2027)
GitHub: [github.com/vanshR18](https://github.com/vanshR18)

---

## License

For educational and portfolio use only. Dataset licenses belong to their respective sources — see each Kaggle dataset page for terms.
