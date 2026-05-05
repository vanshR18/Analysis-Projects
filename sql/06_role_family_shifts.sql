
-- -----------------------------------------------------------------------------
-- Q6.1  Role family posting volume — overall distribution
-- -----------------------------------------------------------------------------
SELECT
    role_family,
    COUNT(*)                                                    AS postings,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2)  AS share_pct,
    COUNT(DISTINCT company)                                     AS unique_companies,
    ROUND(AVG(normalized_salary))                               AS avg_salary
FROM job_postings
GROUP BY role_family
ORDER BY postings DESC;


-- -----------------------------------------------------------------------------
-- Q6.2  Role family volume: Q1 vs Q2 with absolute and % change
-- -----------------------------------------------------------------------------
WITH role_quarter AS (
    SELECT
        role_family,
        SUM(CASE WHEN post_quarter = '2024Q1' THEN 1 ELSE 0 END) AS cnt_q1,
        SUM(CASE WHEN post_quarter = '2024Q2' THEN 1 ELSE 0 END) AS cnt_q2
    FROM job_postings
    WHERE role_family <> 'Other'
      AND post_quarter IN ('2024Q1', '2024Q2')
    GROUP BY role_family
)
SELECT
    role_family,
    cnt_q1,
    cnt_q2,
    cnt_q2 - cnt_q1                                             AS absolute_change,
    ROUND(
        (cnt_q2 - cnt_q1)::NUMERIC / NULLIF(cnt_q1, 0) * 100, 1
    )                                                           AS pct_change,
    CASE
        WHEN cnt_q2 > cnt_q1 THEN 'Growing'
        WHEN cnt_q2 < cnt_q1 THEN 'Shrinking'
        ELSE 'Stable'
    END                                                         AS trend
FROM role_quarter
ORDER BY pct_change DESC;


-- -----------------------------------------------------------------------------
-- Q6.3  AI/LLM Engineer postings by quarter + share of all postings
-- -----------------------------------------------------------------------------
WITH quarter_totals AS (
    SELECT post_quarter, COUNT(*) AS total
    FROM job_postings
    GROUP BY post_quarter
)
SELECT
    jp.post_quarter,
    COUNT(*)                                                    AS ai_postings,
    qt.total                                                    AS total_postings,
    ROUND(COUNT(*)::NUMERIC / qt.total * 100, 3)                AS ai_share_pct
FROM job_postings jp
JOIN quarter_totals qt ON qt.post_quarter = jp.post_quarter
WHERE jp.role_family = 'AI/LLM Engineer'
GROUP BY jp.post_quarter, qt.total
ORDER BY jp.post_quarter;


-- -----------------------------------------------------------------------------
-- Q6.4  Top 10 most active hiring companies
-- -----------------------------------------------------------------------------
SELECT
    company,
    COUNT(*)                                                    AS total_postings,
    COUNT(DISTINCT role_family)                                 AS role_families_hiring,
    ROUND(AVG(normalized_salary))                               AS avg_salary,
    SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END)        AS remote_postings,
    ROUND(
        SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END)
        ::NUMERIC / COUNT(*) * 100, 1
    )                                                           AS remote_pct
FROM job_postings
WHERE company IS NOT NULL
GROUP BY company
ORDER BY total_postings DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q6.5  Layoff impact — companies that laid off and kept hiring
--        Join layoffs table against job_postings on company name
-- -----------------------------------------------------------------------------
SELECT
    jp.company,
    MAX(l.date_announced)                                       AS layoff_date,
    MAX(l.headcount_lost)                                       AS headcount_lost,
    COUNT(DISTINCT jp.job_id)                                   AS postings_after_layoff,
    COUNT(DISTINCT jp.role_family)                              AS roles_hiring,
    ROUND(AVG(jp.normalized_salary))                            AS avg_salary_after
FROM layoffs l
JOIN job_postings jp
    ON LOWER(jp.company) = LOWER(l.company)
   AND jp.posted_date > l.date_announced::TIMESTAMPTZ
WHERE l.headcount_lost > 0
GROUP BY jp.company
HAVING COUNT(DISTINCT jp.job_id) >= 5
ORDER BY headcount_lost DESC
LIMIT 20;


-- -----------------------------------------------------------------------------
-- Q6.6  Remote ratio trend: Q1 vs Q2 2024
--        Is remote work growing or shrinking?
-- -----------------------------------------------------------------------------
SELECT
    post_quarter,
    CASE remote_ratio
        WHEN 0   THEN 'On-site'
        WHEN 100 THEN 'Remote'
        ELSE          'Unknown'
    END                                                         AS work_mode,
    COUNT(*)                                                    AS postings,
    ROUND(COUNT(*)::NUMERIC /
          SUM(COUNT(*)) OVER (PARTITION BY post_quarter) * 100, 2
    )                                                           AS share_pct
FROM job_postings
WHERE remote_ratio IN (0, 100)
GROUP BY post_quarter, remote_ratio
ORDER BY post_quarter, remote_ratio;


-- -----------------------------------------------------------------------------
-- Q6.7  Experience level demand distribution
-- -----------------------------------------------------------------------------
SELECT
    experience_level,
    role_family,
    COUNT(*)                                                    AS postings,
    ROUND(AVG(normalized_salary))                               AS avg_salary,
    ROUND(COUNT(*)::NUMERIC /
          SUM(COUNT(*)) OVER (PARTITION BY role_family) * 100, 1
    )                                                           AS pct_within_role
FROM job_postings
WHERE experience_level NOT IN ('Unknown', 'Other')
  AND role_family <> 'Other'
GROUP BY experience_level, role_family
ORDER BY role_family, postings DESC;
