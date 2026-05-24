#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Push Validation ==="

# Run full preflight
"$SCRIPT_DIR/preflight.sh"

# Verify codegen
"$SCRIPT_DIR/codegen_verify.sh"

# Check import boundaries
"$SCRIPT_DIR/check_imports.sh"

# Check architecture
"$SCRIPT_DIR/check_architecture.sh"

echo ""
echo "=== Push Validation PASSED ==="
