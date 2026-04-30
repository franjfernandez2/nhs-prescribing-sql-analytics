# NHS Prescribing SQL Analytics

SQL portfolio project analysing public NHS English Prescribing Data with PostgreSQL.

The project uses pharmacy domain knowledge and reproducible SQL workflows to identify prescribing cost drivers, regional variation, high-unit-cost medicines, and exploratory practice-level outlier signals.

## Key Results

Analysis was run on the full January 2026 NHSBSA English Prescribing Dataset loaded locally into PostgreSQL.

- Dataset size: 18,342,436 prescribing rows.
- National actual cost analysed: £904,922,906.48.
- Tirzepatide was the highest-cost BNF chemical substance by total actual cost: £67.2m across 292,949 items.
- FreeStyle Libre 2 Plus Sensor was the highest-cost individual presentation: £29.1m actual cost, average £82.47 per item.
- Highest total-cost ICBs included North East and North Cumbria, Greater Manchester, and Cheshire and Merseyside.
- Practice-level outliers are treated as analytical signals only, not as evidence of poor prescribing quality.

Evidence:

```text
outputs/00_validation_checks.txt
outputs/01_top_chemicals_by_cost.txt
outputs/02_top_presentations_by_cost.txt
outputs/03_top_icbs_by_cost.txt
screenshots/validation_results.svg
screenshots/key_findings_outputs.svg
```

## Why This Project Matters

NHS prescribing data contains millions of real-world medicines usage and cost records. This project demonstrates how SQL can be used to answer healthcare analytics questions such as:

- Which medicines and product categories drive the highest prescribing costs?
- How does prescribing cost vary between Integrated Care Boards?
- Which medicines have high average cost per prescribed item?
- Which practice-level records warrant further investigation after appropriate adjustment?

## Tech Stack

- PostgreSQL
- Docker Compose
- SQL
- psql
- Git / GitHub
- Text outputs and SVG evidence screenshots

## Repository Structure

```text
nhs-prescribing-sql-analytics/
├── README.md
├── docker-compose.yml
├── data/                         # local full raw data, ignored by Git
├── sample_data/                  # small committed sample for structure review
├── docs/
│   └── methodology.md
├── scripts/
│   └── run_all_queries.sh
├── sql/
│   ├── 00_schema/
│   ├── 01_basic/
│   ├── 02_intermediate/
│   └── 03_advanced/
├── outputs/
└── screenshots/
```

## Data Source and Data Layout

- Source: NHSBSA Open Data, English Prescribing Dataset (EPD) with SNOMED Code.
- File used: January 2026 EPD with SNOMED Code.
- Official source: https://opendata.nhsbsa.net/dataset/english-prescribing-dataset-epd-with-snomed-code
- Full local file path expected by this project: `data/prescribing_jan_2026.csv`.
- Raw full CSV size locally: approximately 7.2 GB.
- Loaded PostgreSQL table: `raw_prescribing_jan_2026`.

The full raw dataset is not committed to Git because it is several GB. The committed file in `sample_data/` contains 10,000 data rows plus a header row for quick structure review only. Main analysis outputs were generated from the full dataset, not from the sample.

For deeper methodology notes, see:

```text
docs/methodology.md
```

## Quick Reproduction

Start PostgreSQL:

```bash
docker compose up -d
```

Create the schema:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d nhs_prescribing -f sql/00_schema/schema.sql
```

Load the full CSV:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d nhs_prescribing -f sql/00_schema/load_data.sql
```

Create indexes:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d nhs_prescribing -f sql/00_schema/02_indexes.sql
```

Run validation and regenerate all outputs:

```bash
PGPASSWORD=postgres ./scripts/run_all_queries.sh
```

The script regenerates `outputs/00_validation_checks.txt` and all nine analysis output files.

Connection defaults match `docker-compose.yml`:

```text
PGHOST=127.0.0.1
PGPORT=5433
PGDATABASE=nhs_prescribing
PGUSER=postgres
```

You can override these environment variables if needed.

## Analysis Queries

| Area | Query | Output |
| --- | --- | --- |
| Validation | `sql/00_schema/03_validation_checks.sql` | `outputs/00_validation_checks.txt` |
| Top BNF chemicals by cost | `sql/01_basic/01_top_chemicals_by_cost.sql` | `outputs/01_top_chemicals_by_cost.txt` |
| Top presentations by cost | `sql/01_basic/02_top_presentations_by_cost.sql` | `outputs/02_top_presentations_by_cost.txt` |
| Top ICBs by cost | `sql/01_basic/03_top_icbs_by_cost.sql` | `outputs/03_top_icbs_by_cost.txt` |
| Highest cost per item | `sql/01_basic/04_highest_cost_per_item.sql` | `outputs/04_highest_cost_per_item.txt` |
| Top chemicals per ICB | `sql/02_intermediate/01_top_chemicals_per_icb.sql` | `outputs/05_top_chemicals_per_icb.txt` |
| High-cost practices | `sql/02_intermediate/02_high_cost_practices.sql` | `outputs/06_high_cost_practices.txt` |
| Cost per item by chemical | `sql/02_intermediate/03_cost_per_item_by_chemical.sql` | `outputs/07_cost_per_item_by_chemical.txt` |
| ICB rankings with window functions | `sql/03_advanced/01_icb_rankings_window_functions.sql` | `outputs/08_icb_rankings_window_functions.txt` |
| Practice cost outlier detection | `sql/03_advanced/02_practice_cost_outliers.sql` | `outputs/09_practice_cost_outliers.txt` |

## Validation Summary

Validation checks were run against the full January 2026 dataset after loading it into PostgreSQL.

```text
row_count:                    18,342,436
distinct_year_months:         1
min_year_month:               2026-01
max_year_month:               2026-01
distinct_icbs:                43
distinct_practices:           9,279
distinct_chemical_substances: 1,801
national_items:               108,270,468
national_actual_cost:         £904,922,906.48
```

Data quality checks on core analytical fields:

```text
missing_year_month:           0
missing_icb_code:             0
missing_practice_code:        0
missing_chemical_code:        0
null_items:                   0
null_actual_cost:             0
negative_items:               0
negative_actual_cost:         0
```

Full evidence file:

```text
outputs/00_validation_checks.txt
```

## Evidence Screenshots

Validation summary:

![Validation results](screenshots/validation_results.svg)

Query output highlights:

![Query output highlights](screenshots/key_findings_outputs.svg)

The screenshots are visual summaries. The text files in `outputs/` are the source of truth for exact results.

## Interpretation Caveats

High prescribing cost does not automatically indicate inappropriate prescribing, poor clinical practice, waste, or inefficiency.

Practice-level and ICB-level results should be interpreted as signals for further investigation, not as clinical judgements. Proper interpretation would require adjustment for factors such as population size, age distribution, deprivation, disease burden, case mix, specialist responsibilities, prescribing volume, and local formulary choices.

This project focuses on SQL analytics and exploratory healthcare data analysis. It does not assess individual prescriber performance or clinical appropriateness.

## Current Status

Completed:

- Full January 2026 dataset loaded into PostgreSQL.
- Schema, indexes, validation checks, and main analysis queries created.
- Reproducible output regeneration via `scripts/run_all_queries.sh`.
- Text outputs and SVG evidence screenshots committed.
- Methodology notes added in `docs/methodology.md`.
- Large raw CSV excluded from Git.

Planned improvements:

- Add volume-normalised metrics, such as cost per 1,000 items or cost per registered patients if population data is added.
- Add a Python or BI visualisation layer.
- Extend analysis across multiple months for trend analysis.

## Licence and Attribution

The data used in this project comes from NHSBSA Open Data.

According to the NHSBSA Open Data Portal, the English Prescribing Dataset (EPD) with SNOMED Code is licensed under the Open Government Licence v3.0.

Attribution required by the source:

```text
NHSBSA Copyright 2025
```
