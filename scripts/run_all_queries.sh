#!/usr/bin/env bash
set -euo pipefail

# Regenerate all validation and analysis output files for the NHS prescribing SQL project.
#
# Defaults match the local Docker Compose setup in this repository.
# Override any connection setting by exporting PGHOST, PGPORT, PGDATABASE, PGUSER, or PGPASSWORD.
# Example:
#   PGPORT=5433 PGPASSWORD=postgres ./scripts/run_all_queries.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/outputs"

# Keep psql row-count messages stable across machines with different locales.
export LC_ALL=C

PGHOST="${PGHOST:-127.0.0.1}"
PGPORT="${PGPORT:-5433}"
PGDATABASE="${PGDATABASE:-nhs_prescribing}"
PGUSER="${PGUSER:-postgres}"

mkdir -p "$OUTPUT_DIR"

run_query() {
  local sql_file="$1"
  local output_file="$2"

  echo "Running ${sql_file} -> ${output_file}"
  psql \
    -h "$PGHOST" \
    -p "$PGPORT" \
    -U "$PGUSER" \
    -d "$PGDATABASE" \
    -v ON_ERROR_STOP=1 \
    -f "$ROOT_DIR/$sql_file" \
    -o "$ROOT_DIR/$output_file"
}

run_query "sql/00_schema/03_validation_checks.sql" "outputs/00_validation_checks.txt"
run_query "sql/01_basic/01_top_chemicals_by_cost.sql" "outputs/01_top_chemicals_by_cost.txt"
run_query "sql/01_basic/02_top_presentations_by_cost.sql" "outputs/02_top_presentations_by_cost.txt"
run_query "sql/01_basic/03_top_icbs_by_cost.sql" "outputs/03_top_icbs_by_cost.txt"
run_query "sql/01_basic/04_highest_cost_per_item.sql" "outputs/04_highest_cost_per_item.txt"
run_query "sql/02_intermediate/01_top_chemicals_per_icb.sql" "outputs/05_top_chemicals_per_icb.txt"
run_query "sql/02_intermediate/02_high_cost_practices.sql" "outputs/06_high_cost_practices.txt"
run_query "sql/02_intermediate/03_cost_per_item_by_chemical.sql" "outputs/07_cost_per_item_by_chemical.txt"
run_query "sql/03_advanced/01_icb_rankings_window_functions.sql" "outputs/08_icb_rankings_window_functions.txt"
run_query "sql/03_advanced/02_practice_cost_outliers.sql" "outputs/09_practice_cost_outliers.txt"

echo "All outputs regenerated in ${OUTPUT_DIR}"
