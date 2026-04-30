-- 01_top_chemicals_per_icb.sql
-- Top five BNF chemical substances by total actual cost within each ICB.
-- Dataset: NHS English Prescribing Data, January 2026.
-- Output: outputs/05_top_chemicals_per_icb.txt

WITH chemical_costs_by_icb AS (
    SELECT
        icb_name,
        icb_code,
        bnf_chemical_substance,
        SUM(items) AS total_items,
        ROUND(SUM(actual_cost), 2) AS total_actual_cost
    FROM raw_prescribing_jan_2026
    GROUP BY
        icb_name,
        icb_code,
        bnf_chemical_substance
),

ranked_chemicals AS (
    SELECT
        icb_name,
        icb_code,
        bnf_chemical_substance,
        total_items,
        total_actual_cost,
        ROW_NUMBER() OVER (
            PARTITION BY icb_code
            ORDER BY total_actual_cost DESC
        ) AS cost_rank_within_icb
    FROM chemical_costs_by_icb
)

SELECT
    icb_name,
    icb_code,
    cost_rank_within_icb,
    bnf_chemical_substance,
    total_items,
    total_actual_cost
FROM ranked_chemicals
WHERE cost_rank_within_icb <= 5
ORDER BY
    icb_name,
    cost_rank_within_icb;
