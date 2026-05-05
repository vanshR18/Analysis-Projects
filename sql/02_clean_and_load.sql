
-- STEP 1 — Load skills dimension first
TRUNCATE skills RESTART IDENTITY CASCADE;

-- skills_long has columns: job_id, post_year, post_quarter, role_family, era, skill
CREATE TEMP TABLE tmp_skills_long (
    job_id          BIGINT,
    post_year       INT,
    post_quarter    TEXT,
    role_family     TEXT,
    era             TEXT,
    skill           TEXT
);

\COPY tmp_skills_long FROM :'processed_dir' || '/skills_long.csv' CSV HEADER;

INSERT INTO skills (skill_name, category)
SELECT DISTINCT
    skill,
    CASE
        WHEN skill IN ('python','sql','java','scala','r','go','rust',
                       'c++','javascript','typescript','bash')          THEN 'language'
        WHEN skill IN ('spark','kafka','airflow','dbt','pandas',
                       'pytorch','tensorflow','scikit-learn','react',
                       'fastapi','django','spring','langchain',
                       'huggingface')                                   THEN 'framework'
        WHEN skill IN ('aws','azure','gcp','snowflake','databricks',
                       'redshift','bigquery')                           THEN 'cloud'
        WHEN skill IN ('docker','kubernetes','terraform','git',
                       'power bi','tableau','looker','excel',
                       'jira','openai','llm','rag')                     THEN 'tool'
        ELSE 'other'
    END AS category
FROM tmp_skills_long
WHERE skill IS NOT NULL AND skill <> ''
ON CONFLICT (skill_name) DO NOTHING;

SELECT COUNT(*) AS skills_loaded FROM skills;

-- STEP 2 — Load job_postings fact table

TRUNCATE job_postings CASCADE;

-- Staging table matches CSV exactly (generated columns excluded)
CREATE TEMP TABLE tmp_postings (
    job_id              BIGINT,
    title               TEXT,
    company             TEXT,
    company_id          BIGINT,
    location            TEXT,
    city                TEXT,
    state               TEXT,
    posted_date         TEXT,      -- loaded as text, cast below
    role_family         TEXT,
    experience_level    TEXT,
    employment_type     TEXT,
    remote_ratio        TEXT,
    salary_min          TEXT,
    salary_max          TEXT,
    normalized_salary   TEXT,
    description         TEXT,
    raw_skills          TEXT
);

\COPY tmp_postings FROM :'processed_dir' || '/job_postings_with_skills.csv' CSV HEADER;

INSERT INTO job_postings (
    job_id, title, company, company_id, location, city, state,
    posted_date, role_family, experience_level, employment_type,
    remote_ratio, salary_min, salary_max, normalized_salary,
    description, raw_skills
)
SELECT
    job_id,
    title,
    company,
    company_id,
    location,
    city,
    state,
    posted_date::TIMESTAMPTZ,
    role_family,
    experience_level,
    employment_type,
    NULLIF(remote_ratio, '')::INT,
    NULLIF(salary_min,  '')::NUMERIC,
    NULLIF(salary_max,  '')::NUMERIC,
    NULLIF(normalized_salary, '')::NUMERIC,
    description,
    raw_skills
FROM tmp_postings
WHERE job_id IS NOT NULL
ON CONFLICT (job_id) DO NOTHING;

SELECT COUNT(*) AS postings_loaded FROM job_postings;

-- STEP 3 — Populate job_skills bridge from skills_long
TRUNCATE job_skills;

INSERT INTO job_skills (job_id, skill_id)
SELECT DISTINCT
    sl.job_id,
    s.skill_id
FROM tmp_skills_long sl
JOIN skills s ON s.skill_name = sl.skill
JOIN job_postings jp ON jp.job_id = sl.job_id   -- only keep matched postings
WHERE sl.skill IS NOT NULL AND sl.skill <> ''
ON CONFLICT DO NOTHING;

SELECT COUNT(*) AS job_skill_pairs FROM job_skills;

-- STEP 4 — Load layoffs
TRUNCATE layoffs RESTART IDENTITY;

CREATE TEMP TABLE tmp_layoffs (
    company             TEXT,
    location            TEXT,
    headcount_lost      TEXT,
    date_announced      TEXT,
    percentage_laid     TEXT,
    industry            TEXT,
    source              TEXT,
    stage               TEXT,
    funds_raised        TEXT,
    country             TEXT,
    date_added          TEXT
);

\COPY tmp_layoffs FROM :'processed_dir' || '/layoffs_clean.csv' CSV HEADER;

INSERT INTO layoffs (
    company, location, date_announced, headcount_lost,
    percentage_laid, industry, stage, funds_raised, country
)
SELECT
    company,
    location,
    NULLIF(date_announced, '')::DATE,
    COALESCE(NULLIF(headcount_lost, '')::INT, 0),
    NULLIF(percentage_laid, '')::NUMERIC,
    industry,
    stage,
    NULLIF(funds_raised, '')::NUMERIC,
    country
FROM tmp_layoffs
WHERE date_announced IS NOT NULL AND date_announced <> '';

SELECT COUNT(*) AS layoffs_loaded FROM layoffs;

-- STEP 5 — Load salary benchmarks
TRUNCATE salary_benchmarks RESTART IDENTITY;

CREATE TEMP TABLE tmp_salary (
    job_title           TEXT,
    role_family         TEXT,
    experience_level    TEXT,
    employment_type     TEXT,
    work_year           TEXT,
    salary_usd          TEXT,
    remote_ratio        TEXT,
    work_mode           TEXT,
    company_size        TEXT,
    company_location    TEXT
);

\COPY tmp_salary FROM :'processed_dir' || '/salary_benchmarks_clean.csv' CSV HEADER;

INSERT INTO salary_benchmarks (
    job_title, role_family, experience_level, employment_type,
    work_year, salary_usd, remote_ratio, work_mode,
    company_size, company_location
)
SELECT
    job_title,
    role_family,
    experience_level,
    employment_type,
    NULLIF(work_year, '')::INT,
    NULLIF(salary_usd, '')::NUMERIC,
    NULLIF(remote_ratio, '')::INT,
    work_mode,
    LEFT(company_size, 1),
    company_location
FROM tmp_salary;

SELECT COUNT(*) AS benchmarks_loaded FROM salary_benchmarks;

-- STEP 6 — Final row counts summary
SELECT 'job_postings'     AS table_name, COUNT(*) AS rows FROM job_postings
UNION ALL
SELECT 'skills',                          COUNT(*)         FROM skills
UNION ALL
SELECT 'job_skills',                      COUNT(*)         FROM job_skills
UNION ALL
SELECT 'layoffs',                         COUNT(*)         FROM layoffs
UNION ALL
SELECT 'salary_benchmarks',               COUNT(*)         FROM salary_benchmarks
ORDER BY table_name;
