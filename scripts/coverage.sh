#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
cd "$REPO_ROOT"

echo "=== Coverage Report ==="

melos exec --fail-fast --concurrency=1 --dir-exists=test -- "flutter test --exclude-tags golden --exclude-tags benchmark --coverage"

echo ""
echo "Coverage reports generated in each package's coverage/ directory."
echo "See tooling/coverage.yaml for per-package thresholds."
