
-- Q4.1  Salary distribution by role family
--        P25 / median / P75 / avg — filter outliers first

SELECT
    role_family,
    COUNT(*)                                                    AS postings_with_salary,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS p25_salary,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS p75_salary,
    ROUND(AVG(normalized_salary))                               AS avg_salary,
    ROUND(MAX(normalized_salary))                               AS max_salary,
    ROUND(MIN(normalized_salary))                               AS min_salary
FROM job_postings
WHERE normalized_salary BETWEEN 30000 AND 450000
  AND role_family <> 'Other'
GROUP BY role_family
HAVING COUNT(*) > 10
ORDER BY median_salary DESC;


-- Q4.2  Salary by role family AND quarter  (Q1 vs Q2 comparison)

SELECT
    role_family,
    post_quarter,
    COUNT(*)                                                    AS postings,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    ROUND(AVG(normalized_salary))                               AS avg_salary
FROM job_postings
WHERE normalized_salary BETWEEN 30000 AND 450000
  AND role_family <> 'Other'
  AND post_quarter IN ('2024Q1', '2024Q2')
GROUP BY role_family, post_quarter
ORDER BY role_family, post_quarter;



-- Q4.3  Salary premium per skill
--        How much more do jobs listing a given skill pay vs the baseline?

WITH baseline AS (
    SELECT AVG(normalized_salary) AS overall_avg
    FROM job_postings
    WHERE normalized_salary BETWEEN 30000 AND 450000
),
skill_salary AS (
    SELECT
        s.skill_name,
        s.category,
        COUNT(*)                        AS jobs_with_skill,
        AVG(jp.normalized_salary)       AS avg_salary_with_skill
    FROM job_skills  js
    JOIN skills      s  ON s.skill_id = js.skill_id
    JOIN job_postings jp ON jp.job_id  = js.job_id
    WHERE jp.normalized_salary BETWEEN 30000 AND 450000
    GROUP BY s.skill_name, s.category
    HAVING COUNT(*) > 50
)
SELECT
    ss.skill_name,
    ss.category,
    ss.jobs_with_skill,
    ROUND(ss.avg_salary_with_skill)                             AS avg_salary,
    ROUND(b.overall_avg)                                        AS baseline_avg,
    ROUND(ss.avg_salary_with_skill - b.overall_avg)             AS salary_premium,
    ROUND(
        (ss.avg_salary_with_skill - b.overall_avg)
        / b.overall_avg * 100, 1
    )                                                           AS premium_pct
FROM skill_salary ss
CROSS JOIN baseline b
ORDER BY salary_premium DESC;



-- Q4.4  Remote vs On-site salary comparison by role family

SELECT
    role_family,
    CASE remote_ratio
        WHEN 0   THEN 'On-site'
        WHEN 100 THEN 'Remote'
        ELSE          'Other'
    END                                                         AS work_mode,
    COUNT(*)                                                    AS postings,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    ROUND(AVG(normalized_salary))                               AS avg_salary
FROM job_postings
WHERE normalized_salary BETWEEN 30000 AND 450000
  AND role_family <> 'Other'
  AND remote_ratio IN (0, 100)
GROUP BY role_family, remote_ratio
HAVING COUNT(*) > 10
ORDER BY role_family, remote_ratio;



-- Q4.5  Overall remote premium  (single number for summary card)

SELECT
    CASE remote_ratio
        WHEN 0   THEN 'On-site'
        WHEN 100 THEN 'Remote'
    END                                                         AS work_mode,
    COUNT(*)                                                    AS postings,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    ROUND(AVG(normalized_salary))                               AS avg_salary
FROM job_postings
WHERE normalized_salary BETWEEN 30000 AND 450000
  AND remote_ratio IN (0, 100)
GROUP BY remote_ratio
ORDER BY remote_ratio;



-- Q4.6  Salary benchmarks by experience level  (from salary_benchmarks table)

SELECT
    role_family,
    experience_level,
    work_year,
    COUNT(*)                                                    AS sample_size,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY salary_usd))                                AS median_salary_usd,
    ROUND(AVG(salary_usd))                                      AS avg_salary_usd
FROM salary_benchmarks
WHERE salary_usd BETWEEN 30000 AND 500000
  AND role_family <> 'Other'
GROUP BY role_family, experience_level, work_year
HAVING COUNT(*) >= 5
ORDER BY role_family, work_year, experience_level;



-- Q4.7  Top 10 highest paying companies  (min 5 postings with salary)

SELECT
    company,
    COUNT(*)                                                    AS postings_with_salary,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    ROUND(AVG(normalized_salary))                               AS avg_salary,
    ROUND(MAX(normalized_salary))                               AS max_salary
FROM job_postings
WHERE normalized_salary BETWEEN 30000 AND 450000
GROUP BY company
HAVING COUNT(*) >= 5
ORDER BY median_salary DESC
LIMIT 10;
