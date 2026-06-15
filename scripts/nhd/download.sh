#!/usr/bin/env bash
# Download and extract USGS NHD High Resolution HU4 shapefiles for Portland metro.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RAW_DIR="$SCRIPT_DIR/raw"
CONFIG="$SCRIPT_DIR/config.json"

for cmd in curl unzip python3; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: missing config: $CONFIG" >&2
  exit 1
fi

mkdir -p "$RAW_DIR"

readarray -t REGIONS < <(
  python3 - <<'PY' "$CONFIG"
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)

base = config["nhd_base_url"].rstrip("/")
for region in config["huc_regions"]:
    url = f"{base}/{region['url_suffix']}"
    print(f"{region['huc4']}|{url}")
PY
)

echo "=== NHD download (Portland metro HU4) ==="

for entry in "${REGIONS[@]}"; do
  huc4="${entry%%|*}"
  url="${entry#*|}"
  zip_path="$RAW_DIR/NHD_H_${huc4}_HU4_Shape.zip"
  extract_dir="$RAW_DIR/$huc4"

  if find "$extract_dir" -name 'NHDFlowline.shp' -print -quit 2>/dev/null | grep -q .; then
    echo "skip: HUC $huc4 already extracted ($extract_dir)"
    continue
  fi

  if [[ ! -f "$zip_path" ]]; then
    echo "download: $url"
    curl -L --fail --retry 3 --continue-at - -o "$zip_path" "$url"
  else
    echo "reuse zip: $zip_path"
  fi

  mkdir -p "$extract_dir"
  echo "extract: $zip_path -> $extract_dir"
  unzip -oq "$zip_path" -d "$extract_dir"
done

echo "done: raw shapefiles under $RAW_DIR"
