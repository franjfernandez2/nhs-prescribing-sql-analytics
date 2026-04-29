-- 02_indexes.sql
-- Recommended indexes for NHS prescribing analytics queries.
--
-- These indexes help speed up GROUP BY, filtering and ranking queries
-- over the raw prescribing table.
--
-- Run after loading data:
-- psql -h 127.0.0.1 -p 5433 -U postgres -d nhs_prescribing -f sql/00_schema/02_indexes.sql
CREATE INDEX IF NOT EXISTS idx_raw_prescribing_bnf_chemical
ON raw_prescribing_jan_2026 (bnf_chemical_substance);
CREATE INDEX IF NOT EXISTS idx_raw_prescribing_presentation
ON raw_prescribing_jan_2026 (bnf_presentation_name);
CREATE INDEX IF NOT EXISTS idx_raw_prescribing_icb_name
ON raw_prescribing_jan_2026 (icb_name);
CREATE INDEX IF NOT EXISTS idx_raw_prescribing_practice_code
ON raw_prescribing_jan_2026 (practice_code);
CREATE INDEX IF NOT EXISTS idx_raw_prescribing_actual_cost
ON raw_prescribing_jan_2026 (actual_cost);
CREATE INDEX IF NOT EXISTS idx_raw_prescribing_items
ON raw_prescribing_jan_2026 (items);
ANALYZE raw_prescribing_jan_2026;
