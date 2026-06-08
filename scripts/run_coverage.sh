#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
# shellcheck source=preflight_lib.sh
source "$SCRIPT_DIR/preflight_lib.sh"
cd "$REPO_ROOT"
unset GIT_DIR GIT_WORK_TREE

preflight_run_tests --coverage
