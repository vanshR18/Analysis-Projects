
-- SKILLS dimension

CREATE TABLE skills (
    skill_id    SERIAL      PRIMARY KEY,
    skill_name  TEXT        NOT NULL,
    category    TEXT,                       
    CONSTRAINT uq_skill_name UNIQUE (skill_name)
);

-- JOB_POSTINGS fact table

CREATE TABLE job_postings (
    job_id              BIGINT      PRIMARY KEY,
    title               TEXT,
    company             TEXT,
    company_id          BIGINT,
    location            TEXT,
    city                TEXT,
    state               TEXT,
    posted_date         TIMESTAMPTZ,
    post_year           INT         GENERATED ALWAYS AS
                            (EXTRACT(YEAR  FROM posted_date)::INT) STORED,
    post_quarter        TEXT        GENERATED ALWAYS AS
                            (EXTRACT(YEAR  FROM posted_date)::TEXT
                             || 'Q'
                             || EXTRACT(QUARTER FROM posted_date)::TEXT) STORED,
    post_month          TEXT        GENERATED ALWAYS AS
                            (TO_CHAR(posted_date, 'YYYY-MM')) STORED,
    role_family         TEXT,
    experience_level    TEXT,
    employment_type     TEXT,
    remote_ratio        INT         CHECK (remote_ratio IN (0, 50, 100)),
    salary_min          NUMERIC,
    salary_max          NUMERIC,
    salary_mid          NUMERIC     GENERATED ALWAYS AS
                            ((salary_min + salary_max) / 2.0) STORED,
    normalized_salary   NUMERIC,
    description         TEXT,
    raw_skills          TEXT        -- comma-separated skill names
);

-- JOB_SKILLS bridge table  (many-to-many)

CREATE TABLE job_skills (
    job_id      BIGINT  NOT NULL REFERENCES job_postings(job_id) ON DELETE CASCADE,
    skill_id    INT     NOT NULL REFERENCES skills(skill_id)     ON DELETE CASCADE,
    PRIMARY KEY (job_id, skill_id)
);

-- LAYOFFS

CREATE TABLE layoffs (
    layoff_id           SERIAL      PRIMARY KEY,
    company             TEXT,
    location            TEXT,
    date_announced      DATE,
    headcount_lost      INT         DEFAULT 0,
    percentage_laid     NUMERIC,
    industry            TEXT,
    stage               TEXT,
    funds_raised        NUMERIC,
    country             TEXT
);


-- SALARY_BENCHMARKS  (from ds_salaries.csv)

CREATE TABLE salary_benchmarks (
    bench_id            SERIAL      PRIMARY KEY,
    job_title           TEXT,
    role_family         TEXT,
    experience_level    TEXT,       -- EN / MI / SE / EX
    employment_type     TEXT,       -- FT / PT / CT / FL
    work_year           INT,
    salary_usd          NUMERIC,
    remote_ratio        INT,
    work_mode           TEXT,       -- On-site / Hybrid / Remote
    company_size        CHAR(1),    -- S / M / L
    company_location    TEXT
);

-- INDEXES  (applied after bulk load for speed)
CREATE INDEX idx_postings_date         ON job_postings(posted_date);
CREATE INDEX idx_postings_quarter      ON job_postings(post_quarter);
CREATE INDEX idx_postings_year         ON job_postings(post_year);
CREATE INDEX idx_postings_role         ON job_postings(role_family);
CREATE INDEX idx_postings_remote       ON job_postings(remote_ratio);
CREATE INDEX idx_postings_city         ON job_postings(city);
CREATE INDEX idx_postings_company      ON job_postings(LOWER(company));
CREATE INDEX idx_postings_salary       ON job_postings(normalized_salary)
                                       WHERE normalized_salary IS NOT NULL;

CREATE INDEX idx_job_skills_job        ON job_skills(job_id);
CREATE INDEX idx_job_skills_skill      ON job_skills(skill_id);

CREATE INDEX idx_layoffs_company       ON layoffs(LOWER(company));
CREATE INDEX idx_layoffs_date          ON layoffs(date_announced);

CREATE INDEX idx_bench_role            ON salary_benchmarks(role_family);
CREATE INDEX idx_bench_year            ON salary_benchmarks(work_year);

-- Confirm
SELECT
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) AS size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
