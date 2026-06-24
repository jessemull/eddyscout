#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Hydro geometry check ==="
python3 "$SCRIPT_DIR/hydro/check_geometry.py"

echo "=== Hydro geometry unit tests ==="
python3 -m unittest discover -s "$SCRIPT_DIR/hydro" -p 'test_*.py' -v

echo "=== NHD script unit tests ==="
python3 -m unittest discover -s "$SCRIPT_DIR/nhd" -p 'test_*.py' -v

if [[ -f "$SCRIPT_DIR/nhd/output/willamette_waterway.geojson" ]]; then
  echo "=== NHD compare (non-blocking, local output present) ==="
  "$SCRIPT_DIR/nhd/compare_bundled.sh" || echo "WARN: NHD compare failed (non-blocking)"
fi
