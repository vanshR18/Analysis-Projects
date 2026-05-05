
-- -----------------------------------------------------------------------------
-- VIEW 1 — Skill demand by quarter
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_skill_demand_quarterly AS
SELECT
    s.skill_name,
    s.category,
    jp.post_quarter,
    jp.post_year,
    COUNT(*)                                                    AS postings,
    ROUND(COUNT(*)::NUMERIC /
          SUM(COUNT(*)) OVER (PARTITION BY jp.post_quarter) * 100, 3
    )                                                           AS share_pct
FROM job_skills  js
JOIN skills      s  ON s.skill_id = js.skill_id
JOIN job_postings jp ON jp.job_id  = js.job_id
GROUP BY s.skill_name, s.category, jp.post_quarter, jp.post_year;

-- Test
SELECT * FROM vw_skill_demand_quarterly ORDER BY post_quarter, postings DESC LIMIT 10;


-- -----------------------------------------------------------------------------
-- VIEW 2 — Role salary summary
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_role_salary_summary AS
SELECT
    role_family,
    post_quarter,
    post_year,
    COUNT(*)                                                    AS postings,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS p25_salary,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS p75_salary,
    ROUND(AVG(normalized_salary))                               AS avg_salary
FROM job_postings
WHERE normalized_salary BETWEEN 30000 AND 450000
  AND role_family <> 'Other'
GROUP BY role_family, post_quarter, post_year;

-- Test
SELECT * FROM vw_role_salary_summary ORDER BY post_quarter, median_salary DESC;


-- -----------------------------------------------------------------------------
-- VIEW 3 — Skill salary premium
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_skill_salary_premium AS
WITH baseline AS (
    SELECT AVG(normalized_salary) AS overall_avg
    FROM job_postings
    WHERE normalized_salary BETWEEN 30000 AND 450000
)
SELECT
    s.skill_name,
    s.category,
    COUNT(*)                                                    AS jobs_with_skill,
    ROUND(AVG(jp.normalized_salary))                            AS avg_salary_with_skill,
    ROUND(b.overall_avg)                                        AS baseline_avg,
    ROUND(AVG(jp.normalized_salary) - b.overall_avg)            AS salary_premium,
    ROUND(
        (AVG(jp.normalized_salary) - b.overall_avg)
        / b.overall_avg * 100, 1
    )                                                           AS premium_pct
FROM job_skills  js
JOIN skills      s  ON s.skill_id = js.skill_id
JOIN job_postings jp ON jp.job_id  = js.job_id
CROSS JOIN baseline b
WHERE jp.normalized_salary BETWEEN 30000 AND 450000
GROUP BY s.skill_name, s.category, b.overall_avg
HAVING COUNT(*) > 50;

-- Test
SELECT * FROM vw_skill_salary_premium ORDER BY salary_premium DESC LIMIT 15;


-- -----------------------------------------------------------------------------
-- VIEW 4 — City posting summary
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_city_summary AS
SELECT
    city,
    state,
    post_quarter,
    post_year,
    COUNT(*)                                                    AS postings,
    COUNT(DISTINCT company)                                     AS unique_companies,
    ROUND(AVG(normalized_salary))                               AS avg_salary,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END)        AS remote_postings,
    ROUND(
        SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END)
        ::NUMERIC / COUNT(*) * 100, 1
    )                                                           AS remote_pct
FROM job_postings
WHERE city IS NOT NULL
GROUP BY city, state, post_quarter, post_year;

-- Test
SELECT * FROM vw_city_summary ORDER BY postings DESC LIMIT 10;


-- -----------------------------------------------------------------------------
-- VIEW 5 — Role family quarterly shifts
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_role_quarter_summary AS
SELECT
    role_family,
    post_quarter,
    post_year,
    COUNT(*)                                                    AS postings,
    ROUND(COUNT(*)::NUMERIC /
          SUM(COUNT(*)) OVER (PARTITION BY post_quarter) * 100, 2
    )                                                           AS share_of_quarter_pct,
    COUNT(DISTINCT company)                                     AS unique_companies,
    SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END)        AS remote_postings,
    ROUND(AVG(normalized_salary))                               AS avg_salary
FROM job_postings
GROUP BY role_family, post_quarter, post_year;

-- Test
SELECT * FROM vw_role_quarter_summary ORDER BY post_quarter, postings DESC;


-- -----------------------------------------------------------------------------
-- VIEW 6 — Work mode distribution
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_work_mode_summary AS
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
    )                                                           AS share_pct,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary
FROM job_postings
WHERE remote_ratio IN (0, 100)
  AND normalized_salary BETWEEN 30000 AND 450000
GROUP BY post_quarter, remote_ratio;

-- Test
SELECT * FROM vw_work_mode_summary ORDER BY post_quarter, work_mode;


-- -----------------------------------------------------------------------------
-- VIEW 7 — Layoff vs hiring overview
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_layoff_hiring_impact AS
SELECT
    jp.company,
    MAX(l.date_announced)                                       AS layoff_date,
    MAX(l.headcount_lost)                                       AS headcount_lost,
    MAX(l.industry)                                             AS industry,
    COUNT(DISTINCT jp.job_id)                                   AS postings_after_layoff,
    COUNT(DISTINCT jp.role_family)                              AS roles_hiring,
    ROUND(AVG(jp.normalized_salary))                            AS avg_salary_posted,
    STRING_AGG(DISTINCT jp.role_family, ', ')                   AS roles_list
FROM layoffs l
JOIN job_postings jp
    ON LOWER(jp.company) = LOWER(l.company)
   AND jp.posted_date > l.date_announced::TIMESTAMPTZ
WHERE l.headcount_lost > 0
GROUP BY jp.company
HAVING COUNT(DISTINCT jp.job_id) >= 5
ORDER BY headcount_lost DESC;

-- Test
SELECT * FROM vw_layoff_hiring_impact LIMIT 10;


-- -----------------------------------------------------------------------------
-- Final: list all views created
-- -----------------------------------------------------------------------------
SELECT
    viewname,
    pg_size_pretty(pg_total_relation_size(quote_ident(viewname))) AS size
FROM pg_views
WHERE schemaname = 'public'
  AND viewname LIKE 'vw_%'
ORDER BY viewname;
