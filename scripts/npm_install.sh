#!/usr/bin/env bash
# Installs root Node deps and verifies package-lock name stays pinned (worktree-safe).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

readonly EXPECTED_NAME="eddyscout"

if ! command -v npm &>/dev/null; then
  echo "ERROR: npm not found. Install Node.js, then re-run."
  exit 1
fi

if ! node -e "
  const pkg = require('./package.json');
  if (pkg.name !== '$EXPECTED_NAME') {
    console.error(
      'ERROR: package.json must include \"name\": \"$EXPECTED_NAME\" ' +
      '(got: ' + JSON.stringify(pkg.name) + ').',
    );
    console.error(
      'Without a pinned name, npm uses the worktree folder name in package-lock.json.',
    );
    process.exit(1);
  }
"; then
  exit 1
fi

npm install

node -e "
  const lock = require('./package-lock.json');
  const root = lock.packages?.['']?.name ?? lock.name;
  if (lock.name !== '$EXPECTED_NAME' || (root && root !== '$EXPECTED_NAME')) {
    console.error(
      'ERROR: package-lock.json name drifted (lock=' +
        JSON.stringify(lock.name) +
        ', root=' +
        JSON.stringify(root) +
        '). Expected \"$EXPECTED_NAME\".',
    );
    process.exit(1);
  }
"
