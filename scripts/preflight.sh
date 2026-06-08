#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
# shellcheck source=preflight_lib.sh
source "$SCRIPT_DIR/preflight_lib.sh"
cd "$REPO_ROOT"
# Git worktrees inject GIT_DIR into hooks; melos/dart then resolve Flutter SDK incorrectly.
unset GIT_DIR GIT_WORK_TREE

STAGED_ONLY=false
CI_MODE=false
SKIP_COVERAGE=false
AFFECTED_TESTS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged) STAGED_ONLY=true; shift ;;
    --ci) CI_MODE=true; shift ;;
    --no-coverage) SKIP_COVERAGE=true; shift ;;
    --affected) AFFECTED_TESTS=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if $AFFECTED_TESTS; then
  export PUSH_VALIDATE_AFFECTED=1
fi

PREFLIGHT_START=$SECONDS
JOBS="$(preflight_resolve_jobs)"
echo "=== EddyScout Preflight (melos concurrency: ${JOBS}) ==="

_preflight_format() {
  if $STAGED_ONLY; then
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACMR -- '*.dart' || true)
    if [[ -n "$staged_files" ]]; then
      echo "$staged_files" | xargs dart format --set-exit-if-changed
    else
      echo "No staged Dart files."
    fi
  else
    melos exec --concurrency="$JOBS" -- "dart format --set-exit-if-changed ."
  fi
}

_preflight_analyze() {
  # Packages first (excludes app), then app separately (workspace layout).
  melos exec --concurrency="$JOBS" --ignore=eddyscout -- "dart analyze --fatal-infos"
  melos exec --scope=eddyscout -- "dart analyze --fatal-infos"
}

if $STAGED_ONLY; then
  preflight_phase_start "Format (staged)"
  _preflight_format
  preflight_phase_end "Format (staged)"

  preflight_phase_start "Analyze (staged)"
  staged_files=$(git diff --cached --name-only --diff-filter=ACMR -- '*.dart' || true)
  if [[ -n "$staged_files" ]]; then
    echo "$staged_files" | xargs dart analyze --fatal-infos
  else
    echo "No staged Dart files."
  fi
  preflight_phase_end "Analyze (staged)"
else
  preflight_run_parallel \
    "Format" _preflight_format \
    "Analyze" _preflight_analyze \
    "Import boundaries" "$SCRIPT_DIR/check_imports.sh" \
    "Architecture" "$SCRIPT_DIR/check_architecture.sh"

  preflight_run_parallel \
    "Tests" "$SCRIPT_DIR/run_tests.sh" \
    "Codegen verification" "$SCRIPT_DIR/codegen_verify.sh"

  if ! $SKIP_COVERAGE; then
    preflight_phase_start "Coverage thresholds"
    "$SCRIPT_DIR/run_coverage.sh"
    "$SCRIPT_DIR/check_coverage.sh"
    preflight_phase_end "Coverage thresholds"
  fi
fi

echo ""
echo "=== Preflight PASSED ($((SECONDS - PREFLIGHT_START))s total) ==="
