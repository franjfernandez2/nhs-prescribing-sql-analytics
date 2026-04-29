-- 03_high_cost_practices.sql
-- GP practices with the highest total actual prescribing cost.
-- Dataset: NHS English Prescribing Data, January 2026.

SELECT
    icb_name,
    icb_code,
    practice_name,
    practice_code,
    postcode,
    SUM(items) AS total_items,
    COUNT(DISTINCT bnf_chemical_substance_code) AS distinct_chemicals,
    ROUND(SUM(actual_cost), 2) AS total_actual_cost,
    ROUND(SUM(actual_cost) / NULLIF(SUM(items), 0), 2) AS avg_cost_per_item
FROM raw_prescribing_jan_2026
GROUP BY
    icb_name,
    icb_code,
    practice_name,
    practice_code,
    postcode
ORDER BY total_actual_cost DESC
LIMIT 50;
