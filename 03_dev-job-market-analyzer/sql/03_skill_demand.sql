
-- Q3.1  Top 20 skills by total posting volume

SELECT
    s.skill_name,
    s.category,
    COUNT(*)                                            AS total_postings,
    ROUND(COUNT(*)::NUMERIC / (
        SELECT COUNT(DISTINCT job_id) FROM job_skills
    ) * 100, 2)                                         AS pct_of_all_jobs
FROM job_skills  js
JOIN skills      s  ON s.skill_id  = js.skill_id
GROUP BY s.skill_name, s.category
ORDER BY total_postings DESC
LIMIT 20;


-- Q3.2  Skill demand by quarter  (absolute count + market share)

WITH quarterly_totals AS (
    SELECT post_quarter, COUNT(DISTINCT job_id) AS total_jobs
    FROM job_postings
    GROUP BY post_quarter
)
SELECT
    s.skill_name,
    s.category,
    jp.post_quarter,
    COUNT(*)                                            AS postings_with_skill,
    qt.total_jobs,
    ROUND(COUNT(*)::NUMERIC / qt.total_jobs * 100, 2)  AS skill_share_pct,
    RANK() OVER (
        PARTITION BY jp.post_quarter
        ORDER BY COUNT(*) DESC
    )                                                   AS rank_in_quarter
FROM job_skills  js
JOIN skills      s  ON s.skill_id  = js.skill_id
JOIN job_postings jp ON jp.job_id  = js.job_id
JOIN quarterly_totals qt ON qt.post_quarter = jp.post_quarter
GROUP BY s.skill_name, s.category, jp.post_quarter, qt.total_jobs
ORDER BY jp.post_quarter, postings_with_skill DESC;


-- Q3.3  Skill demand shift Q1 → Q2 2024  (% change + absolute delta)

WITH per_quarter AS (
    SELECT
        s.skill_name,
        s.category,
        SUM(CASE WHEN jp.post_quarter = '2024Q1' THEN 1 ELSE 0 END) AS cnt_q1,
        SUM(CASE WHEN jp.post_quarter = '2024Q2' THEN 1 ELSE 0 END) AS cnt_q2
    FROM job_skills  js
    JOIN skills      s  ON s.skill_id = js.skill_id
    JOIN job_postings jp ON jp.job_id  = js.job_id
    WHERE jp.post_quarter IN ('2024Q1', '2024Q2')
    GROUP BY s.skill_name, s.category
    HAVING SUM(CASE WHEN jp.post_quarter = '2024Q1' THEN 1 ELSE 0 END) > 30
)
SELECT
    skill_name,
    category,
    cnt_q1,
    cnt_q2,
    cnt_q2 - cnt_q1                                             AS absolute_change,
    ROUND(
        (cnt_q2 - cnt_q1)::NUMERIC / NULLIF(cnt_q1, 0) * 100, 1
    )                                                           AS pct_change,
    CASE
        WHEN cnt_q2 > cnt_q1 THEN 'Rising'
        WHEN cnt_q2 < cnt_q1 THEN 'Falling'
        ELSE 'Stable'
    END                                                         AS trend
FROM per_quarter
ORDER BY pct_change DESC;


-- Q3.4  Fastest rising skills  (top 15 by % growth)

WITH per_quarter AS (
    SELECT
        s.skill_name,
        s.category,
        SUM(CASE WHEN jp.post_quarter = '2024Q1' THEN 1 ELSE 0 END) AS cnt_q1,
        SUM(CASE WHEN jp.post_quarter = '2024Q2' THEN 1 ELSE 0 END) AS cnt_q2
    FROM job_skills  js
    JOIN skills      s  ON s.skill_id = js.skill_id
    JOIN job_postings jp ON jp.job_id  = js.job_id
    WHERE jp.post_quarter IN ('2024Q1', '2024Q2')
    GROUP BY s.skill_name, s.category
    HAVING SUM(CASE WHEN jp.post_quarter = '2024Q1' THEN 1 ELSE 0 END) > 30
)
SELECT
    skill_name,
    category,
    cnt_q1,
    cnt_q2,
    ROUND((cnt_q2 - cnt_q1)::NUMERIC / cnt_q1 * 100, 1) AS pct_change
FROM per_quarter
WHERE cnt_q2 > cnt_q1
ORDER BY pct_change DESC
LIMIT 15;


-- Q3.5  Fastest falling skills  (top 15 by % decline)

WITH per_quarter AS (
    SELECT
        s.skill_name,
        s.category,
        SUM(CASE WHEN jp.post_quarter = '2024Q1' THEN 1 ELSE 0 END) AS cnt_q1,
        SUM(CASE WHEN jp.post_quarter = '2024Q2' THEN 1 ELSE 0 END) AS cnt_q2
    FROM job_skills  js
    JOIN skills      s  ON s.skill_id = js.skill_id
    JOIN job_postings jp ON jp.job_id  = js.job_id
    WHERE jp.post_quarter IN ('2024Q1', '2024Q2')
    GROUP BY s.skill_name, s.category
    HAVING SUM(CASE WHEN jp.post_quarter = '2024Q1' THEN 1 ELSE 0 END) > 30
)
SELECT
    skill_name,
    category,
    cnt_q1,
    cnt_q2,
    ROUND((cnt_q2 - cnt_q1)::NUMERIC / cnt_q1 * 100, 1) AS pct_change
FROM per_quarter
WHERE cnt_q2 < cnt_q1
ORDER BY pct_change ASC
LIMIT 15;

-
-- Q3.6  Skill co-occurrence with Python
--        What other skills appear in the same JD as Python?
  
WITH python_jobs AS (
    SELECT js.job_id
    FROM job_skills js
    JOIN skills     s ON s.skill_id = js.skill_id
    WHERE s.skill_name = 'python'
),
python_total AS (
    SELECT COUNT(*) AS n FROM python_jobs
)
SELECT
    s.skill_name                                                AS co_skill,
    s.category,
    COUNT(*)                                                    AS co_occurrences,
    ROUND(
        COUNT(*)::NUMERIC / pt.n * 100, 1
    )                                                           AS pct_of_python_jobs
FROM job_skills  js
JOIN python_jobs pj ON pj.job_id  = js.job_id
JOIN skills      s  ON s.skill_id = js.skill_id
CROSS JOIN python_total pt
WHERE s.skill_name <> 'python'
GROUP BY s.skill_name, s.category, pt.n
ORDER BY co_occurrences DESC
LIMIT 25;


-- Q3.7  Skill demand by role family
--        Which skills define each role?  (top 5 skills per role family)
WITH role_skill_counts AS (
    SELECT
        jp.role_family,
        s.skill_name,
        COUNT(*)                                                AS cnt,
        RANK() OVER (
            PARTITION BY jp.role_family
            ORDER BY COUNT(*) DESC
        )                                                       AS skill_rank
    FROM job_skills  js
    JOIN skills      s  ON s.skill_id = js.skill_id
    JOIN job_postings jp ON jp.job_id  = js.job_id
    WHERE jp.role_family <> 'Other'
    GROUP BY jp.role_family, s.skill_name
)
SELECT
    role_family,
    skill_name,
    cnt,
    skill_rank
FROM role_skill_counts
WHERE skill_rank <= 5
ORDER BY role_family, skill_rank;
