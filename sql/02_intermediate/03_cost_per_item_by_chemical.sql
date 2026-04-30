-- 03_cost_per_item_by_chemical.sql
-- Highest average cost per item by BNF chemical substance.
-- A minimum item threshold avoids tiny-volume chemicals dominating the ranking.
-- Dataset: NHS English Prescribing Data, January 2026.
-- Output: outputs/07_cost_per_item_by_chemical.txt

SELECT
    bnf_chemical_substance_code,
    bnf_chemical_substance,
    SUM(items) AS total_items,
    ROUND(SUM(actual_cost), 2) AS total_actual_cost,
    ROUND(SUM(actual_cost) / NULLIF(SUM(items), 0), 2) AS avg_cost_per_item
FROM raw_prescribing_jan_2026
GROUP BY
    bnf_chemical_substance_code,
    bnf_chemical_substance
HAVING SUM(items) >= 1000
ORDER BY avg_cost_per_item DESC
LIMIT 20;
