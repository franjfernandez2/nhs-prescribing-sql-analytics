-- schema.sql
-- Creates the raw table used by the NHS prescribing analysis queries.
-- Dataset: NHS English Prescribing Data, January 2026.

DROP TABLE IF EXISTS raw_prescribing_jan_2026;

CREATE TABLE raw_prescribing_jan_2026 (
    year_month TEXT,
    regional_office_name TEXT,
    regional_office_code TEXT,
    icb_name TEXT,
    icb_code TEXT,
    pco_name TEXT,
    pco_code TEXT,
    practice_name TEXT,
    practice_code TEXT,
    address_1 TEXT,
    address_2 TEXT,
    address_3 TEXT,
    address_4 TEXT,
    postcode TEXT,
    bnf_chemical_substance_code TEXT,
    bnf_chemical_substance TEXT,
    bnf_presentation_code TEXT,
    bnf_presentation_name TEXT,
    bnf_chapter_plus_code TEXT,
    quantity NUMERIC,
    items INTEGER,
    total_quantity NUMERIC,
    adq_usage NUMERIC,
    nic NUMERIC(14, 5),
    actual_cost NUMERIC(14, 5),
    unidentified TEXT,
    snomed_code TEXT
);

-- Example load command:
-- \copy raw_prescribing_jan_2026
-- FROM 'data/prescribing_jan_2026.csv'
-- WITH (FORMAT csv, HEADER true);
