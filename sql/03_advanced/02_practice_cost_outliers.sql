-- 02_practice_cost_outliers.sql
-- GP practices with unusually high total prescribing costs compared with peers in the same ICB.
-- Uses ICB-level quartiles and the interquartile range to flag high-cost outliers.
-- Dataset: NHS English Prescribing Data, January 2026.
-- Output: outputs/09_practice_cost_outliers.txt

WITH practice_costs AS (
    SELECT
        icb_name,
        icb_code,
        practice_name,
        practice_code,
        postcode,
        SUM(items) AS total_items,
        ROUND(SUM(actual_cost), 2) AS total_actual_cost,
        ROUND(SUM(actual_cost) / NULLIF(SUM(items), 0), 2) AS avg_cost_per_item
    FROM raw_prescribing_jan_2026
    GROUP BY
        icb_name,
        icb_code,
        practice_name,
        practice_code,
        postcode
),

icb_quartiles AS (
    SELECT
        icb_code,
        percentile_cont(0.25) WITHIN GROUP (ORDER BY total_actual_cost) AS q1_total_actual_cost,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY total_actual_cost) AS q3_total_actual_cost
    FROM practice_costs
    GROUP BY icb_code
),

practice_outliers AS (
    SELECT
        practice_costs.icb_name,
        practice_costs.icb_code,
        practice_costs.practice_name,
        practice_costs.practice_code,
        practice_costs.postcode,
        practice_costs.total_items,
        practice_costs.total_actual_cost,
        practice_costs.avg_cost_per_item,
        ROUND(icb_quartiles.q1_total_actual_cost::numeric, 2) AS icb_q1_total_actual_cost,
        ROUND(icb_quartiles.q3_total_actual_cost::numeric, 2) AS icb_q3_total_actual_cost,
        ROUND(
            (
                icb_quartiles.q3_total_actual_cost
                + 1.5 * (
                    icb_quartiles.q3_total_actual_cost
                    - icb_quartiles.q1_total_actual_cost
                )
            )::numeric,
            2
        ) AS high_cost_outlier_threshold
    FROM practice_costs
    INNER JOIN icb_quartiles
        ON practice_costs.icb_code = icb_quartiles.icb_code
)

SELECT
    icb_name,
    icb_code,
    practice_name,
    practice_code,
    postcode,
    total_items,
    total_actual_cost,
    avg_cost_per_item,
    icb_q1_total_actual_cost,
    icb_q3_total_actual_cost,
    high_cost_outlier_threshold,
    ROUND(total_actual_cost - high_cost_outlier_threshold, 2) AS amount_above_threshold
FROM practice_outliers
WHERE total_actual_cost > high_cost_outlier_threshold
ORDER BY amount_above_threshold DESC
LIMIT 100;
