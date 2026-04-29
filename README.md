# NHS Prescribing SQL Analytics

## Project Overview

This project analyses NHS English Prescribing Data using PostgreSQL.

The goal is to explore prescribing cost patterns across England, identify high-cost BNF chemical substances, compare regional variation across Integrated Care Boards (ICBs), and build reproducible SQL analyses suitable for a healthcare analytics portfolio.

This project combines my pharmacy background with SQL, data analysis, and healthcare domain knowledge.

## Why This Project Matters

NHS prescribing data contains millions of rows of real-world medicines usage and cost information.

Analysing this data can help answer questions such as:

- Which medicines or product categories drive the highest prescribing costs?
- How does prescribing cost vary between ICBs?
- Which GP practices appear to have unusually high cost patterns?
- What is the relationship between prescribing volume, item count, and actual cost?
- Can SQL be used to generate clinically relevant and operationally useful healthcare insights?

## Tools Used

- PostgreSQL
- Docker
- SQL
- CSV outputs
- Git and GitHub

## Repository Structure

```text
nhs-prescribing-sql-analytics/
├── README.md
├── data/
├── sql/
│   ├── 00_schema/
│   ├── 01_basic/
│   ├── 02_intermediate/
│   └── 03_advanced/
├── outputs/
├── screenshots/
└── docs/
```

## Data Source

This project uses public NHSBSA Open Data.

- Dataset: English Prescribing Dataset (EPD) with SNOMED Code
- Publisher: NHS Business Services Authority (NHSBSA)
- File used: English Prescribing Dataset (EPD) with SNOMED code - Jan 2026
- Local filename: `data/prescribing_jan_2026.csv`
- Official source: https://opendata.nhsbsa.net/dataset/english-prescribing-dataset-epd-with-snomed-code

The raw CSV is not committed to this repository because it is several GB in size. To reproduce the project, download the January 2026 CSV or ZIP from the official NHSBSA Open Data page, extract it if needed, and save it locally as:

```text
data/prescribing_jan_2026.csv
```

After placing the file locally, create the database table and load the data using:

```text
sql/00_schema/schema.sql
sql/00_schema/load_data.sql
```

The raw dataset includes prescribing activity by:

- Year and month
- Regional office
- Integrated Care Board (ICB)
- Primary Care Organisation (PCO)
- GP practice
- BNF chemical substance
- BNF presentation
- Quantity
- Items
- Actual cost
- NIC
- SNOMED code

The data was loaded into a PostgreSQL table called:

```sql
raw_prescribing_jan_2026
```

## Analyses

### 1. Top BNF chemical substances by actual cost

- Query: `sql/01_basic/01_top_chemicals_by_cost.sql`
- Output: `outputs/01_top_chemicals_by_cost.csv`
- Screenshot: `screenshots/01_top_chemicals_by_cost.png`

This query ranks BNF chemical substances by total actual cost, helping identify which medicines or product groups drive the highest prescribing spend.

## How To Reproduce

1. Download the January 2026 file from the official NHSBSA dataset page.
2. Save the extracted CSV locally as `data/prescribing_jan_2026.csv`.
3. Create the PostgreSQL table using `sql/00_schema/schema.sql`.
4. Load the CSV into PostgreSQL using `sql/00_schema/load_data.sql`.
5. Run the SQL files in the `sql/` folder.
6. Export query results into `outputs/`.

The recommended PostgreSQL connection command is:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres -d nhs_prescribing
```

## Licence and Attribution

The data used in this project comes from NHSBSA Open Data.

According to the NHSBSA Open Data Portal, the English Prescribing Dataset (EPD) with SNOMED Code is licensed under the Open Government Licence v3.0.

Attribution required by the source:

```text
NHSBSA Copyright 2025
```

## Learning Goals

- Write readable SQL queries.
- Use aggregation, ordering, grouping, and filtering.
- Build a reproducible analytics project.
- Document analysis clearly for a technical portfolio.
- Connect healthcare knowledge with data analysis.
