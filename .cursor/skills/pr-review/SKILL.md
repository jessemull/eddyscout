---
name: pr-review
description: >-
  Review pull requests for EddyScout: diff-first, code-only, actionable task lists.
  Use when reviewing a PR/branch, triaging review feedback, or deciding merge blockers.
---

# PR Review

**Severity definitions:** `docs/REVIEW.md` (when MUST vs SHOULD is ambiguous).

**This skill controls:** review scope, output shape, and what counts as merge-blocking.

**Governance:** skim `CONTEXT.md` + `AGENTS.md`; load other docs only when the diff touches that domain.

---

## What PR review is (and is not)

**Review:** code, tests, and architecture **in the diff** (plus files that must change to land the change correctly).

**Not review:** PR description quality, commit message format, template checklists, CI green (unless you ran checks and found a specific failure), merge process, or backlog work unrelated to this branch.

---

## Principles

1. **Diff-first** — read the change before generic checklists.
2. **Risk-scoped depth** — lite for tiny PRs; deep for auth, navigation, deps, large refactors.
3. **One bullet = one task** — imperative, fixable; no separate Issue/Fix blocks.
4. **No checklist theater** — do not dump full `docs/REVIEW.md` into the output.
5. **Nothing hedged in actionable tiers** — no "consider", "probably fine", "optional".

---

## Step 1 — Gather context

```bash
git fetch origin main
git log --oneline origin/main..HEAD
git diff origin/main...HEAD --stat
git diff origin/main...HEAD
# Optional: gh pr view / gh pr checks (do not fail if gh missing)
```

Note: packages touched, risk tags, approximate size. Use PR body/commits for **intent only** — do not review prose as findings.

---

## Step 2 — Classify depth (internal)

| Depth | When |
|-------|------|
| **Lite** | Docs/lockfile only, or < ~50 LOC Dart |
| **Standard** | Typical 1–2 package feature/fix |
| **Deep** | Auth, navigation, new deps, cross-package refactor, > ~400 LOC |

**Risk tags:** UI, state, navigation, networking, persistence, security, platform, codegen, architecture, dependencies.

Do **not** include depth/risk tables in the review output unless the user asks.

---

## Step 3 — Classify each finding

Before writing output, assign every finding to exactly one bucket:

| Bucket | Meaning |
|--------|---------|
| **[MUST]** | Merge blocker. Fix **in this branch**. Introduced or worsened by this PR, or required to ship the change safely. |
| **[SHOULD]** | Fix **in this branch** before merge (same actionability as MUST; lower bar: polish, edge tests, consistency in touched files). |
| **[OUT OF SCOPE]** | Real issue, but **pre-existing** or belongs to another feature/backlog slice — **not** this PR. Record so nothing is lost; **does not** block merge. |
| **[VERIFY]** | Might be a problem; static review insufficient. One **concrete** check (command, test, scenario) — not a fix yet. |

### Scope rules

**In scope for [MUST] / [SHOULD]:**

- Files in the diff
- Tests/docs required to land the change
- Regressions **this PR introduces** (even in messy adjacent code)

**→ [OUT OF SCOPE], not [MUST]/[SHOULD]:**

- Pre-existing debt in untouched files
- Backlog items (`docs/ARCHITECTURE_BACKLOG.md`) unless **this PR newly violates** them
- Refactors larger than the PR's stated goal

**→ [VERIFY], not [MUST]/[SHOULD]:**

- Uncertainty without evidence — state what to run/check; no "probably okay"

### Severity hints (this repo)

Often **[MUST]:** cross-feature import; hand-edited `*.g.dart`/`*.freezed.dart`; secrets/PII in logs; `throw` across package boundary; missing error UI for new async paths; `context` after `await` without `mounted`; new behavior without tests.

Often **[SHOULD]:** missing `const` in touched widgets; weak error copy in touched UI; edge case test in touched module; l10n for new user-facing string.

---

## Step 4 — Spot-check (when useful)

```bash
melos exec --scope=<package> -- "flutter test test/<relevant>_test.dart"
# Deep/high-risk only: make preflight
```

Do not list "run preflight" as a review finding unless a specific test/analyze failure was observed.

---

## Output format

Use **only** these sections. **Omit empty sections** (no "None").

```markdown
## Summary

<2 sentences: what changed, verdict>

## [MUST]

- `path/to/file.dart:42` — <single imperative task>
- `path/to/other_test.dart` — <single imperative task>

## [SHOULD]

- `path/to/file.dart:10` — <single imperative task>

## [OUT OF SCOPE]

- `path/to/existing.dart:88` — <clear problem>; pre-existing; address in <feature/backlog area>
- `other/package.dart:1` — <clear problem>; outside this PR's goal

## [VERIFY]

- `path/to/file.dart:55` — Run `<command>` or add `<test>` to confirm whether <specific behavior> fails

## Verdict

**Approve** | **Request changes**
```

### Bullet rules

- Format: `` `file:line` — Task `` (line optional if file-level)
- Task is **imperative**: "Add test …", "Map failure to AppFailure …", "Use l10n key …"
- **No** subheadings per finding, **no** Issue/Fix/Suggested fix split
- **No** duplicate bullets for the same task across sections

### Verdict rules

- **Request changes** — any [MUST] or [SHOULD] item exists
- **Approve** — no [MUST] or [SHOULD]; [OUT OF SCOPE] and [VERIFY] may be present
- When user says "fix the review" — implement **only** [MUST] and [SHOULD]

---

## Banned output (never write)

- "Follow-up PR", "separate PR", "track in issue", "defer to later"
- "Update PR description", "add test plan to PR", Conventional Commits reminders
- "Consider …", "might want to …", "probably acceptable", "optional improvement"
- "Run make preflight" / "ensure CI passes" without a specific observed failure
- Findings in files not in the diff (except [OUT OF SCOPE] with explicit path)
- **NICE TO HAVE** section — use [SHOULD] if fix in-branch, [OUT OF SCOPE] if not
- Hedged items with no action ("could be a problem but leave as-is")

---

## Anti-patterns (review process)

- Reading every governance doc for a one-line fix
- Copying `docs/REVIEW.md` PR hygiene checklist into findings
- Generic "add tests" without naming file and scenario
- Inflating style nits to [MUST] unless CI/analyzer fails
- Assuming `gh` exists

---

## Quick reference

| Topic | Doc |
|-------|-----|
| Severity policy | `docs/REVIEW.md` |
| Architecture | `docs/ARCHITECTURE.md`, `docs/ARCHITECTURE_BACKLOG.md` |
| Riverpod | `docs/STATE_MANAGEMENT.md` |
| Routes | `docs/NAVIGATION.md` |
| Tests | `docs/TESTING.md` |
| Errors | `docs/ERROR_HANDLING.md` |
