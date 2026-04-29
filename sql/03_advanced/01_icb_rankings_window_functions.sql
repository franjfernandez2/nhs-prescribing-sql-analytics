-- 01_icb_rankings_window_functions.sql
-- ICB cost rankings using window functions.
-- Dataset: NHS English Prescribing Data, January 2026.

WITH icb_costs AS (
    SELECT
        icb_name,
        icb_code,
        SUM(items) AS total_items,
        ROUND(SUM(actual_cost), 2) AS total_actual_cost,
        ROUND(SUM(actual_cost) / NULLIF(SUM(items), 0), 2) AS avg_cost_per_item
    FROM raw_prescribing_jan_2026
    GROUP BY
        icb_name,
        icb_code
)

SELECT
    icb_name,
    icb_code,
    total_items,
    total_actual_cost,
    avg_cost_per_item,
    RANK() OVER (ORDER BY total_actual_cost DESC) AS cost_rank,
    RANK() OVER (ORDER BY avg_cost_per_item DESC) AS avg_cost_per_item_rank,
    ROUND(
        100 * total_actual_cost / SUM(total_actual_cost) OVER (),
        2
    ) AS percent_of_national_cost,
    ROUND(
        100 * SUM(total_actual_cost) OVER (
            ORDER BY total_actual_cost DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(total_actual_cost) OVER (),
        2
    ) AS cumulative_percent_of_national_cost
FROM icb_costs
ORDER BY cost_rank
LIMIT 50;
