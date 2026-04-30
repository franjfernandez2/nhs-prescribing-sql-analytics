-- 03_validation_checks.sql
-- Basic validation checks for the loaded NHS prescribing dataset.
-- Dataset: NHS English Prescribing Data, January 2026.
-- Purpose: Confirm row counts, date range, key dimensions, nulls, negative values, and sample records before running analysis queries.

-- 1. Overall dataset shape and national totals.
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT year_month) AS distinct_year_months,
    MIN(year_month) AS min_year_month,
    MAX(year_month) AS max_year_month,
    COUNT(DISTINCT icb_code) AS distinct_icbs,
    COUNT(DISTINCT practice_code) AS distinct_practices,
    COUNT(DISTINCT bnf_chemical_substance_code) AS distinct_chemical_substances,
    SUM(items) AS national_items,
    ROUND(SUM(actual_cost), 2) AS national_actual_cost
FROM raw_prescribing_jan_2026;

-- 2. Basic data quality checks for key analytical fields.
SELECT
    COUNT(*) FILTER (WHERE year_month IS NULL OR year_month = '') AS missing_year_month,
    COUNT(*) FILTER (WHERE icb_code IS NULL OR icb_code = '') AS missing_icb_code,
    COUNT(*) FILTER (WHERE practice_code IS NULL OR practice_code = '') AS missing_practice_code,
    COUNT(*) FILTER (WHERE bnf_chemical_substance_code IS NULL OR bnf_chemical_substance_code = '') AS missing_chemical_code,
    COUNT(*) FILTER (WHERE items IS NULL) AS null_items,
    COUNT(*) FILTER (WHERE actual_cost IS NULL) AS null_actual_cost,
    COUNT(*) FILTER (WHERE items < 0) AS negative_items,
    COUNT(*) FILTER (WHERE actual_cost < 0) AS negative_actual_cost
FROM raw_prescribing_jan_2026;

-- 3. Sample rows for manual inspection of loaded values.
SELECT
    year_month,
    icb_name,
    icb_code,
    practice_name,
    practice_code,
    bnf_chemical_substance,
    bnf_presentation_name,
    items,
    actual_cost
FROM raw_prescribing_jan_2026
ORDER BY year_month, icb_code, practice_code
LIMIT 10;
