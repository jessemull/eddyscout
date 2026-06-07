#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [[ -x .husky/_/pre-push ]]; then
  echo "husky: hooks OK"
  exit 0
fi

echo "husky: .husky/_/ missing (common in new git worktrees)"

echo "husky: running npm install to generate hook stubs..."
"$SCRIPT_DIR/npm_install.sh"

if [[ -x .husky/_/pre-push ]]; then
  echo "husky: hooks installed"
  exit 0
fi

echo "ERROR: husky install failed — .husky/_/pre-push still missing"
echo "Try: npx husky"
exit 1
