-- 02_top_presentations_by_cost.sql
-- Top 20 BNF presentations by total actual cost.
-- Dataset: NHS English Prescribing Data, January 2026.
-- Output: outputs/02_top_presentations_by_cost.txt

SELECT
    bnf_presentation_code,
    bnf_presentation_name,
    SUM(items) AS total_items,
    ROUND(SUM(actual_cost), 2) AS total_actual_cost,
    ROUND(SUM(actual_cost) / NULLIF(SUM(items), 0), 2) AS avg_cost_per_item
FROM raw_prescribing_jan_2026
GROUP BY
    bnf_presentation_code,
    bnf_presentation_name
ORDER BY total_actual_cost DESC
LIMIT 20;
