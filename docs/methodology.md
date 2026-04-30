# Methodology

This document explains how the NHS prescribing SQL analysis was built and how the evidence in this repository should be interpreted.

## 1. Data Source

This project uses the public NHSBSA English Prescribing Dataset (EPD) with SNOMED Code for January 2026.

The full raw CSV is stored locally under `data/` and is not committed to Git because it is several GB in size. The committed `sample_data/` file is a small extract for structure review only.

## 2. Repository Data Layout

```text
data/
```

Used for the full local raw dataset, for example:

```text
data/prescribing_jan_2026.csv
```

This folder is ignored by Git for large raw files.

```text
sample_data/
```

Used for small committed sample data that allows reviewers to inspect column structure without downloading the full dataset.

The analysis outputs in `outputs/` were generated from the full January 2026 dataset, not from the sample file.

## 3. Ingestion Approach

The raw CSV is loaded into PostgreSQL into a single raw analytical table:

```text
raw_prescribing_jan_2026
```

The workflow is intentionally simple and transparent:

1. Create the raw table using `sql/00_schema/schema.sql`.
2. Load the full CSV using `sql/00_schema/load_data.sql`.
3. Add analytical indexes using `sql/00_schema/02_indexes.sql`.
4. Validate the loaded dataset using `sql/00_schema/03_validation_checks.sql`.
5. Run the analysis queries and export text outputs.

## 4. Validation Approach

Validation is performed before interpreting analytical outputs.

The validation checks cover:

- total row count
- month range
- distinct ICB count
- distinct practice count
- distinct BNF chemical substance count
- national item total
- national actual cost total
- missing key fields
- null numeric values
- negative item or cost values
- representative sample rows for manual inspection

The captured validation output is stored in:

```text
outputs/00_validation_checks.txt
```

This provides a reviewable evidence trail rather than relying only on README claims.

## 5. Analysis Approach

The SQL analysis is split into three levels:

```text
sql/01_basic/
```

Basic aggregation queries, such as top BNF chemical substances, top presentations, top ICBs, and highest cost per item.

```text
sql/02_intermediate/
```

Grouped and comparative analysis, such as top chemicals within each ICB, high-cost practices, and cost per item by chemical substance.

```text
sql/03_advanced/
```

More advanced analytical patterns, including window functions and exploratory outlier detection.

All output files can be regenerated with:

```bash
PGPASSWORD=postgres ./scripts/run_all_queries.sh
```

## 6. Evidence and Reproducibility

The project includes several evidence layers:

- SQL scripts in `sql/`
- captured text outputs in `outputs/`
- validation evidence in `outputs/00_validation_checks.txt`
- lightweight SVG evidence screenshots in `screenshots/`
- a one-command output regeneration script in `scripts/run_all_queries.sh`

The screenshots are visual summaries. The text outputs remain the source of truth for exact query results.

## 7. Interpretation Limits

The analysis identifies prescribing cost patterns and outlier signals. It does not judge prescribing quality or clinical appropriateness.

High cost can be influenced by:

- practice population size
- age distribution
- deprivation
- disease burden
- specialist prescribing responsibilities
- local formulary choices
- prescribing volume
- medicine price changes
- case mix

Practice-level and ICB-level results should therefore be interpreted as signals for further investigation, not as conclusions about performance.

## 8. Future Methodological Improvements

Useful next improvements would include:

- cost per 1,000 registered patients if practice population data is added
- cost per 1,000 items or volume-normalised comparisons
- deprivation or demographic adjustment
- time-series analysis across multiple months
- visualisation layer in Python or BI tooling

These are intentionally not claimed as completed in the current project.
