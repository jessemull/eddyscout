---
name: push-validation
description: >-
  Final quality gate before pushing changes to remote. Use when preparing
  to push a branch, finishing a feature, or before opening a pull request.
---

# Push Validation

Read the following before pushing any changes to remote:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/GOVERNANCE.md`
- `docs/TESTING.md`
- `docs/ARCHITECTURE.md`
- `docs/DEPENDENCIES.md`
- `docs/CODEGEN.md`
- `docs/SECURITY.md`
- `docs/PERFORMANCE.md`

Companion skills:
- `commit` — commit conventions and pre-commit checks
- `testing` — test strategy and coverage requirements
- `code-generation` — codegen freshness verification
- `security-review` — secrets and dependency security checks

Push validation is the **final quality gate** before sharing code externally.

It ensures:
- repository integrity
- deterministic builds
- passing CI
- correct architecture
- no stale generated artifacts
- no hidden regressions

---

# When to Use

Use this skill when:

- preparing to push a branch
- finishing a feature
- completing a bug fix
- after dependency updates
- after code generation changes
- before opening a pull request
- before requesting review

---

# Core Push Principles

## CI Is the Source of Truth

Local success is not enough.

All code must:
- pass CI
- be reproducible
- be deterministic
- build cleanly from scratch

---

## No Stale Artifacts Allowed

Generated code must always be:
- up to date
- reproducible
- committed correctly

Never push:
- outdated codegen
- partially regenerated files
- local-only fixes

---

## Test Integrity Is Mandatory

Tests must be:
- deterministic
- repeatable
- environment-independent
- non-flaky

---

# 1. Full Preflight Validation

Run full validation suite:

```bash
make preflight
```

## Must Pass:

- [ ] `dart format` passes
- [ ] `dart analyze` passes (no errors or fatal infos)
- [ ] `flutter test` passes
- [ ] `make gen-check` passes

If any fail:
- fix issues before proceeding
- do NOT suppress errors

---

# 2. Code Generation Validation

## Required Check

```bash id="push1"
make gen-check
```

## If Stale:

- [ ] run `make gen`
- [ ] verify generated output
- [ ] commit regenerated files with source changes

## Rules

- [ ] never hand-edit generated files
- [ ] never push without syncing generated code
- [ ] generated code must match source exactly

---

# 3. Test Validation

## Scope Strategy

### Affected Packages Only

```bash id="push2"
melos run test --since=origin/main
```

## Full Suite (required when uncertain)

```bash
make test
```

## Rules

- [ ] all tests pass
- [ ] no skipped tests without justification
- [ ] no flaky tests tolerated
- [ ] deterministic execution required

---

# 4. Coverage Validation

## Coverage Run

```bash id="push3"
flutter test --coverage
```

## Requirements

- [ ] coverage meets threshold in `docs/TESTING.md`
- [ ] new code includes corresponding tests
- [ ] coverage regressions are justified or fixed

---

# 5. Dependency Validation

- [ ] no unauthorized dependencies added
- [ ] all new dependencies documented
- [ ] dependency versions resolved correctly
- [ ] no conflicting transitive updates

If dependencies changed:
- [ ] run full test suite
- [ ] verify platform compatibility
- [ ] verify security implications

---

# 6. Security Pre-Push Check

- [ ] no secrets committed
- [ ] no PII in logs or state
- [ ] no insecure API usage
- [ ] no unsafe platform channels
- [ ] no bypassed auth logic

---

# 7. Performance Sanity Check

- [ ] no obvious rebuild regressions
- [ ] no new heavy synchronous work in UI
- [ ] no large unoptimized lists introduced
- [ ] no memory leaks introduced

---

# 8. Final Git Validation

## Branch Check

- [ ] correct feature branch
- [ ] no direct pushes to main

## Commit Hygiene

- [ ] conventional commits used
- [ ] logical grouping of changes
- [ ] no unrelated changes bundled

---

# 9. Push Execution

## Push Command

```bash id="push4"
git push -u origin HEAD
```

## Post-Push Checks

- [ ] CI pipeline triggered
- [ ] CI passes or is in progress
- [ ] no immediate red flags in logs

---

# 10. CI Monitoring

After push:

- [ ] verify GitHub Actions status
- [ ] confirm all checks green
- [ ] investigate failures immediately if any occur

---

# 11. Common Push Anti-Patterns

## MUST NOT

- [ ] push with failing tests
- [ ] push with failing analyzer
- [ ] push stale generated code
- [ ] bypass preflight checks
- [ ] push partially completed features
- [ ] ignore coverage regressions

## SHOULD AVOID

- [ ] mixing unrelated changes
- [ ] large unreviewable commits
- [ ] pushing without local CI parity
- [ ] skipping manual verification of generated code

---

# 12. Validation Summary (Optional Output)

When completing push validation, provide:

## Pre-Push Summary
- checks run
- status of each gate

## Risk Assessment
- potential CI risks
- dependency risks
- test coverage risks

## Confidence Statement
- readiness for CI
- expected failure points (if any)