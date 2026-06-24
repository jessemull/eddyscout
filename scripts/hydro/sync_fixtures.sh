#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC="$REPO_ROOT/apps/eddyscout/assets/hydro"
DST="$REPO_ROOT/packages/features/hydro_routing/test/fixtures"

mkdir -p "$DST"
for file in "$SRC"/*_waterway.geojson; do
  cp "$file" "$DST/$(basename "$file")"
done
echo "Synced $(basename "$SRC")/*_waterway.geojson -> test/fixtures/"
