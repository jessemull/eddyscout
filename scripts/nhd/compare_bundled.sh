#!/usr/bin/env bash
# Compare NHD output GeoJSON against bundled OSM hydro assets.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HYDRO_DIR="$REPO_ROOT/apps/eddyscout/assets/hydro"
OUTPUT_DIR="$SCRIPT_DIR/output"
REPORT="$OUTPUT_DIR/compare_report.md"

if [[ ! -f "$OUTPUT_DIR/willamette_waterway.geojson" ]]; then
  echo "NHD compare skipped: no output in $OUTPUT_DIR" >&2
  echo "Run: make hydro-nhd-run  (or hydro-nhd-convert after download)" >&2
  exit 0
fi

./ensure_venv.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/.venv/bin/activate"

rm -f "$REPORT"

compare_system() {
  local label="$1"
  shift
  local system_filter="${1:-}"
  shift
  local candidate="$1"
  shift
  local overlay="$OUTPUT_DIR/${candidate##*/}"
  overlay="${overlay/_waterway.geojson/_compare_overlay.geojson}"

  local -a args=(
    --label "$label"
    --candidate "$OUTPUT_DIR/$candidate"
    --report-out "$REPORT"
    --overlay-out "$overlay"
  )
  if [[ -n "$system_filter" ]]; then
    args+=(--system "$system_filter")
  fi
  for baseline in "$@"; do
    args+=(--baseline "$baseline")
  done
  python3 "$SCRIPT_DIR/compare.py" "${args[@]}"
}

compare_system \
  "Willamette" \
  willamette \
  willamette_waterway.geojson \
  "$HYDRO_DIR/willamette_waterway.geojson"

compare_system \
  "Columbia (lower + gorge + Sandy)" \
  columbia \
  columbia_waterway.geojson \
  "$HYDRO_DIR/columbia_lower_waterway.geojson" \
  "$HYDRO_DIR/columbia_gorge_waterway.geojson" \
  "$HYDRO_DIR/sandy_waterway.geojson"

if [[ -f "$OUTPUT_DIR/clackamas_waterway.geojson" ]]; then
  compare_system \
    "Clackamas" \
    clackamas \
    clackamas_waterway.geojson \
    "$HYDRO_DIR/clackamas_waterway.geojson"
fi

echo "=== NHD compare report: $REPORT ==="
