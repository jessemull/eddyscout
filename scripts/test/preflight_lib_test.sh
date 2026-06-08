#!/usr/bin/env bash
# Unit tests for scripts/preflight_lib.sh (run from repo root).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../preflight_lib.sh
source "$ROOT/scripts/preflight_lib.sh"

assert_eq() {
  local expected=$1
  local actual=$2
  local label=$3
  if [[ "$expected" != "$actual" ]]; then
    echo "FAIL: $label — expected '$expected', got '$actual'"
    exit 1
  fi
}

assert_true() {
  local label=$1
  if ! "$2"; then
    echo "FAIL: $label — expected true"
    exit 1
  fi
}

assert_false() {
  local label=$1
  if "$2"; then
    echo "FAIL: $label — expected false"
    exit 1
  fi
}

cd "$ROOT"

# Jobs resolve from env override.
PUSH_VALIDATE_JOBS=3
assert_eq "3" "$(preflight_resolve_jobs)" "PUSH_VALIDATE_JOBS override"
unset PUSH_VALIDATE_JOBS

# Codegen skip heuristics (no CI, no full flag).
unset CI CODEGEN_VERIFY_FULL
preflight_collect_diff_files() { true; }
assert_false "empty diff needs codegen build" preflight_needs_codegen_build
unset -f preflight_collect_diff_files

preflight_collect_diff_files() { echo "packages/core/lib/src/result.dart"; }
assert_true "lib change needs codegen build" preflight_needs_codegen_build

preflight_collect_diff_files() { echo "docs/README.md"; }
assert_false "docs-only skip codegen build" preflight_needs_codegen_build

preflight_collect_diff_files() { echo "packages/core/lib/src/result.g.dart"; }
assert_false "generated-only skip codegen build" preflight_needs_codegen_build

# CI always runs full codegen.
export CI=true
preflight_collect_diff_files() { echo "docs/README.md"; }
assert_true "CI forces codegen build" preflight_needs_codegen_build
unset CI

# Global config detection.
preflight_collect_diff_files() { echo "scripts/preflight.sh"; }
assert_true "scripts change is global config" preflight_global_config_changed

preflight_collect_diff_files() { echo "packages/map/lib/src/foo.dart"; }
assert_false "package lib change is not global config" preflight_global_config_changed

# Affected tests opt-in.
unset PUSH_VALIDATE_AFFECTED PUSH_VALIDATE_AUTO_AFFECTED
assert_false "affected off by default" preflight_should_use_affected_tests

export PUSH_VALIDATE_AFFECTED=1
assert_true "PUSH_VALIDATE_AFFECTED=1 enables affected" preflight_should_use_affected_tests
unset PUSH_VALIDATE_AFFECTED

export PUSH_VALIDATE_AUTO_AFFECTED=1
preflight_collect_diff_files() { echo "Makefile"; }
assert_false "auto affected falls back when global config changed" preflight_should_use_affected_tests
unset PUSH_VALIDATE_AUTO_AFFECTED

export PUSH_VALIDATE_FULL_SUITE=1
assert_false "full suite flag disables affected tests" preflight_should_use_affected_tests
unset PUSH_VALIDATE_FULL_SUITE

echo "preflight_lib_test: OK"
