
-- Q5.1  Top 20 hiring cities overall

SELECT
    city,
    state,
    COUNT(*)                                                    AS postings,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2)  AS market_share_pct,
    ROUND(AVG(normalized_salary))                               AS avg_salary,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    COUNT(DISTINCT company)                                     AS unique_companies
FROM job_postings
WHERE city IS NOT NULL
GROUP BY city, state
HAVING COUNT(*) > 50
ORDER BY postings DESC
LIMIT 20;


-- -----------------------------------------------------------------------------
-- Q5.2  Top 10 states by posting volume
-- -----------------------------------------------------------------------------
SELECT
    state,
    COUNT(*)                                                    AS postings,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2)  AS share_pct,
    COUNT(DISTINCT city)                                        AS distinct_cities,
    COUNT(DISTINCT company)                                     AS distinct_companies,
    ROUND(AVG(normalized_salary))                               AS avg_salary
FROM job_postings
WHERE state IS NOT NULL
GROUP BY state
ORDER BY postings DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q5.3  City posting share shift: Q1 → Q2 2024
--        Which cities gained or lost market share between quarters?
-- -----------------------------------------------------------------------------
WITH top_cities AS (
    SELECT city
    FROM job_postings
    WHERE city IS NOT NULL
    GROUP BY city
    HAVING COUNT(*) > 100
),
city_quarter AS (
    SELECT
        jp.city,
        jp.post_quarter,
        COUNT(*)                                                AS cnt
    FROM job_postings jp
    JOIN top_cities tc ON tc.city = jp.city
    WHERE jp.post_quarter IN ('2024Q1', '2024Q2')
    GROUP BY jp.city, jp.post_quarter
),
quarter_totals AS (
    SELECT post_quarter, SUM(cnt) AS total
    FROM city_quarter
    GROUP BY post_quarter
),
city_shares AS (
    SELECT
        cq.city,
        cq.post_quarter,
        cq.cnt,
        ROUND(cq.cnt::NUMERIC / qt.total * 100, 3)             AS share_pct
    FROM city_quarter  cq
    JOIN quarter_totals qt ON qt.post_quarter = cq.post_quarter
)
SELECT
    city,
    MAX(CASE WHEN post_quarter = '2024Q1' THEN share_pct END)  AS share_q1,
    MAX(CASE WHEN post_quarter = '2024Q2' THEN share_pct END)  AS share_q2,
    ROUND(
        MAX(CASE WHEN post_quarter = '2024Q2' THEN share_pct END)
        - MAX(CASE WHEN post_quarter = '2024Q1' THEN share_pct END),
        3
    )                                                           AS share_change_pp
FROM city_shares
GROUP BY city
HAVING
    MAX(CASE WHEN post_quarter = '2024Q1' THEN share_pct END) IS NOT NULL
    AND MAX(CASE WHEN post_quarter = '2024Q2' THEN share_pct END) IS NOT NULL
ORDER BY share_change_pp DESC;


-- -----------------------------------------------------------------------------
-- Q5.4  Salary vs volume scatter data  (for Power BI scatter plot)
--        Each row = one city with posting count + median salary
-- -----------------------------------------------------------------------------
SELECT
    city,
    state,
    COUNT(*)                                                    AS postings,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY normalized_salary))                         AS median_salary,
    ROUND(AVG(normalized_salary))                               AS avg_salary,
    SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END)        AS remote_postings,
    ROUND(
        SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END)
        ::NUMERIC / COUNT(*) * 100, 1
    )                                                           AS remote_pct
FROM job_postings
WHERE city IS NOT NULL
  AND normalized_salary BETWEEN 30000 AND 450000
GROUP BY city, state
HAVING COUNT(*) > 30
ORDER BY postings DESC;


-- -----------------------------------------------------------------------------
-- Q5.5  Role family distribution by city
--        What kind of roles does each major city hire for?
-- -----------------------------------------------------------------------------
WITH top_cities AS (
    SELECT city FROM job_postings
    WHERE city IS NOT NULL
    GROUP BY city ORDER BY COUNT(*) DESC LIMIT 10
),
city_role AS (
    SELECT
        jp.city,
        jp.role_family,
        COUNT(*)                                                AS cnt,
        RANK() OVER (
            PARTITION BY jp.city
            ORDER BY COUNT(*) DESC
        )                                                       AS role_rank
    FROM job_postings jp
    JOIN top_cities tc ON tc.city = jp.city
    WHERE jp.role_family <> 'Other'
    GROUP BY jp.city, jp.role_family
)
SELECT city, role_family, cnt, role_rank
FROM city_role
WHERE role_rank <= 3
ORDER BY city, role_rank;
