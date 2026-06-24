#!/usr/bin/env bash
# Run the full NHD pipeline: download → convert → validate.
#
# Usage (from repo root or scripts/nhd/):
#   ./scripts/nhd/run.sh
#   ./scripts/nhd/run.sh -- --system willamette
#   ./scripts/nhd/run.sh -- --no-simplify
#
# Arguments after `--` are passed to convert.py only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

convert_args=()
if [[ "${1:-}" == "--" ]]; then
  shift
  convert_args=("$@")
fi

echo "=== NHD pipeline: download ===" >&2
./download.sh

./ensure_venv.sh

# shellcheck disable=SC1091
source .venv/bin/activate

echo "=== NHD pipeline: convert ===" >&2
python3 convert.py "${convert_args[@]}"

echo "=== NHD pipeline: validate ===" >&2
python3 validate.py

echo "=== NHD pipeline: done (output in $SCRIPT_DIR/output/) ===" >&2
