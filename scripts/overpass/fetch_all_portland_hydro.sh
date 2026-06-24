#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo "=== Fetch Portland metro hydro assets from Overpass ==="

python3 "$SCRIPT_DIR/fetch_willamette_waterway.py"
python3 "$SCRIPT_DIR/fetch_columbia_waterway.py"
python3 "$SCRIPT_DIR/fetch_clackamas_waterway.py"
python3 "$SCRIPT_DIR/fetch_slough_waterway.py"
python3 "$SCRIPT_DIR/fetch_tualatin_waterway.py"
python3 "$SCRIPT_DIR/fetch_sandy_waterway.py"

echo "=== Validate bundled geometry ==="
"$REPO_ROOT/scripts/check_hydro_geometry.sh"

echo "=== Fetch complete ==="
