-- 01_top_chemicals_by_cost.sql
-- Top 20 BNF chemical substances by total actual cost.
-- Dataset: NHS English Prescribing Data, January 2026.
-- Output: outputs/01_top_chemicals_by_cost.txt

SELECT
    bnf_chemical_substance,
    SUM(items) AS total_items,
    ROUND(SUM(actual_cost), 2) AS total_actual_cost
FROM raw_prescribing_jan_2026
GROUP BY bnf_chemical_substance
ORDER BY total_actual_cost DESC
LIMIT 20;
