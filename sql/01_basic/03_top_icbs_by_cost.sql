-- 03_top_icbs_by_cost.sql
-- Top 20 Integrated Care Boards by total actual prescribing cost.
-- Dataset: NHS English Prescribing Data, January 2026.
-- Output: outputs/03_top_icbs_by_cost.txt

SELECT
    icb_name,
    icb_code,
    SUM(items) AS total_items,
    ROUND(SUM(actual_cost), 2) AS total_actual_cost,
    ROUND(SUM(actual_cost) / NULLIF(SUM(items), 0), 2) AS avg_cost_per_item
FROM raw_prescribing_jan_2026
GROUP BY icb_name, icb_code
ORDER BY total_actual_cost DESC
LIMIT 20;
