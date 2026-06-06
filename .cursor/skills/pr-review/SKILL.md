---
name: pr-review
description: >-
  Review pull requests for EddyScout: diff-first, risk-scoped, governance-aligned.
  Use when reviewing a PR/branch, triaging review feedback, or deciding merge blockers.
---

# PR Review

**Canonical severity policy and checklists:** `docs/REVIEW.md` (wins on severity disputes).

**Governance:** skim `CONTEXT.md` + `AGENTS.md` first; load other docs only when the diff touches that domain.

---

## Principles

1. **Diff-first** — read the actual change before generic checklists.
2. **Risk-scoped depth** — small PRs get a light pass; high-risk PRs get full scrutiny.
3. **Evidence-based** — every finding cites a file/line or observable behavior.
4. **No checklist theater** — do not mark 18 sections when only two files changed.
5. **Actionable output** — MUST items need a concrete fix, not vague advice.

---

## Step 1 — Gather context

Run what is available (do not fail the review if `gh` is missing):

```bash
# Branch vs main
git fetch origin main
git log --oneline origin/main..HEAD
git diff origin/main...HEAD --stat
git diff origin/main...HEAD

# If gh is installed
gh pr view <number> --json title,body,files,commits
gh pr checks <number>
```

Extract:

- PR description / test plan (or commit messages if no PR)
- Packages/features touched
- Approximate size (lines, file count)
- CI status if visible

---

## Step 2 — Classify depth

Pick **one** review depth:

| Depth | When | What to verify |
|-------|------|----------------|
| **Lite** | Docs-only, lockfile-only, comment-only, < ~50 LOC Dart | Correctness of change, no accidental code, links accurate |
| **Standard** | Typical feature/fix in 1–2 packages | `docs/REVIEW.md` hygiene + architecture + tests for touched code |
| **Deep** | Auth, navigation, state overhaul, new deps, cross-package refactor, > ~400 LOC | Full `docs/REVIEW.md` + relevant conditional docs from `AGENTS.md` |

**Risk tags** (mark all that apply): UI, state, navigation, networking, persistence, security, platform, codegen, architecture, CI, dependencies.

Use companion skills only when needed: `riverpod-usage`, `security-review`, `accessibility-review`, `testing`, `navigation-change`.

---

## Step 3 — Review the diff

Focus on what **changed**, in priority order:

1. **Correctness** — logic bugs, null safety, async gaps, `mounted` checks
2. **Architecture** — `presentation → domain ← data`, no cross-feature imports, no `packages/` → `apps/`
3. **State** — Riverpod only, no business logic in `build()`, `AsyncValue` loading/error/data
4. **Errors** — `Result` / `AppFailure` at boundaries; user-friendly error UI
5. **Tests** — behavior change has tests; deterministic; `mocktail` only
6. **Codegen** — no hand-edited `*.g.dart` / `*.freezed.dart`; run `make gen-check` if models/providers changed
7. **Security** — no secrets, no PII in logs
8. **A11y / perf** — only for UI-touching PRs

**Common MUST issues in this repo:**

- Feature importing another feature package
- `throw` across package boundary instead of `Result` / `AppFailure`
- Generated files manually edited
- New dependency without approval
- Missing `AsyncValue` error UI on new async screens
- `context` used after `await` without `mounted`

**Do not inflate severity:** style-only → NICE TO HAVE unless CI/analyzer fails.

---

## Step 4 — Verify claims

If the PR says tests pass, spot-check:

```bash
# Targeted (preferred for review)
melos exec --scope=<package> -- "flutter test test/<relevant>_test.dart"

# Or full gate when high-risk
make preflight
```

Skip full preflight for lite reviews unless the author claims it or the change is high-risk.

---

## Output format

Use exactly this structure:

```markdown
## Summary

<What changed, depth used, risk level, verdict>

## Change risk

- Categories: …
- Depth: Lite | Standard | Deep
- Risk: Low | Medium | High | Critical

## MUST

### <title>
- **Files:** `path:line` …
- **Issue:** …
- **Fix:** …

(omit section if none)

## SHOULD

### <title>
- **Files:** …
- **Issue:** …
- **Fix:** …

## NICE TO HAVE

(bullet list or omit)

## Verification gaps

What you could not confirm from diff alone (e.g. CI green, manual device test).

## Verdict

**Approve** | **Request changes** | **Comment**
```

**Verdict rules:**

- **Request changes** — any MUST item
- **Approve** — no MUST; SHOULD noted or absent
- **Comment** — no MUST; useful SHOULD/NICE only

---

## Anti-patterns (avoid)

- Reading every doc in `CONTEXT.md` for a one-line fix
- Copying the entire `docs/REVIEW.md` checklist into the review output
- Generic “consider adding tests” without naming what's untested
- Blocking on NICE TO HAVE items
- Reviewing files not in the diff
- Assuming `gh` exists — use `git diff` fallbacks

---

## Quick reference

| Topic | Doc |
|-------|-----|
| Severity | `docs/REVIEW.md` |
| Architecture | `docs/ARCHITECTURE.md`, `docs/ARCHITECTURE_BACKLOG.md` |
| Riverpod | `docs/STATE_MANAGEMENT.md` |
| Routes | `docs/NAVIGATION.md` |
| Tests | `docs/TESTING.md` |
| Errors | `docs/ERROR_HANDLING.md` |
