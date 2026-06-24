#!/usr/bin/env bash
# Create scripts/nhd/.venv and install Python dependencies for the NHD pipeline.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required for the NHD pipeline." >&2
  exit 1
fi

if [[ ! -d .venv ]]; then
  echo "nhd: creating .venv in $SCRIPT_DIR" >&2
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate

pip install -q -r requirements.txt

if ! python3 - <<'PY'
import fiona  # noqa: F401
PY
then
  echo "ERROR: fiona failed to import (GDAL shared libraries required)." >&2
  echo "  macOS: brew install gdal" >&2
  echo "  Ubuntu: sudo apt install gdal-bin libgdal-dev" >&2
  exit 1
fi

echo "nhd: venv ready ($SCRIPT_DIR/.venv)" >&2
