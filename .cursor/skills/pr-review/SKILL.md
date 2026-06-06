---
name: pr-review
description: >-
  Review pull requests for EddyScout: diff-first, code-only, fixed-section task lists.
  Use when reviewing a PR/branch, triaging review feedback, or deciding merge blockers.
---

# PR Review

**Severity definitions:** `docs/REVIEW.md` (when MUST vs SHOULD vs NICE is ambiguous).

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
4. **Checklists are internal** — work through `docs/REVIEW.md` by domain; **never paste** checklist tables into the review output.
5. **Fixed sections** — always render all output sections; use `(no items)` when a section has no content.
6. **No hedging in actionable tiers** — no "consider", "probably fine", "optional" in MUST/SHOULD/NICE bullets.

---

## Step 1 — Gather context

```bash
git fetch origin main
git log --oneline origin/main..HEAD
git diff origin/main...HEAD --stat
git diff origin/main...HEAD --shortstat
git diff origin/main...HEAD
# Optional: gh pr view / gh pr checks (do not fail if gh missing)
```

From the diff, collect for output:

- **Scope:** commit count, file count, `+additions / -deletions`, packages touched, change type (fix / refactor / feat / docs / chore — infer from diff, not author checkbox)
- **Risk:** one line — Low / Medium / High + why (e.g. state, auth, cross-package)
- **Architecture:** one line — OK or concern (e.g. cross-feature import, Result at boundary)
- **Files changed** table: one row per changed file, brief purpose of change
- **Reviewed areas:** domains from Step 3 that were applied; list N/A domains in parentheses
- **Breaking changes:** public API, provider signature, route, or contract changes callers must update
- **Strengths:** concrete positives in touched code (tests, patterns, clarity)
- **Test plan:** specific commands and manual scenarios for this PR

Use PR body/commits for **intent only** — do not review prose as findings.

---

## Step 2 — Classify depth (internal)

| Depth | When |
|-------|------|
| **Lite** | Docs/lockfile only, or < ~50 LOC Dart |
| **Standard** | Typical 1–2 package feature/fix |
| **Deep** | Auth, navigation, new deps, cross-package refactor, > ~400 LOC |

**Risk tags:** UI, state, navigation, networking, persistence, security, platform, codegen, architecture, dependencies.

Do **not** include the depth table in the review output — fold risk into **Scope** (one line).

---

## Step 3 — Review against checklists (internal)

Use `docs/REVIEW.md` as the **review rubric**. Apply only sections relevant to the diff (mark others N/A mentally — list N/A in **Reviewed areas**, not as bullets).

| If the diff touches… | Read & apply `docs/REVIEW.md` section |
|----------------------|----------------------------------------|
| Any Dart / Flutter code | Architecture review checklist |
| Providers / notifiers | Riverpod / state review |
| Widgets / screens | Widget design review |
| Lists / images / animations | Rebuild / performance review |
| `await` / navigation / routes | Lifecycle & async safety; Navigation review |
| Errors / API / offline | Error-state review |
| User-visible UI | Accessibility review |
| Secrets / network / WebView | Security review |
| `*.g.dart` / freezed / routes | Codegen review (also `docs/CODEGEN.md`) |
| `pubspec.yaml` | Dependency review |
| Tests added/changed | Testing review |
| `android/` / `ios/` / `web/` | Platform review |
| ARB / strings | Localization review |
| Analytics events | Analytics / privacy review |

**Skip for reviewers:** `docs/REVIEW.md` § PR hygiene (description template, commit format, PR size) — author responsibility, not code review.

**Depth guidance:**

- **Lite:** Architecture + correctness for changed files only.
- **Standard:** Architecture + Riverpod (if providers) + Widget (if UI) + Testing + Error-state (if I/O).
- **Deep:** All applicable sections above; read conditional docs from `AGENTS.md`.

Companion skills for deep passes: `riverpod-usage`, `security-review`, `accessibility-review`, `testing`, `navigation-change`.

Findings from checklists become output bullets in Step 4 — not copied checklist rows.

---

## Step 4 — Classify each finding

Assign every finding to exactly one bucket:

| Bucket | Blocks merge? | Meaning |
|--------|---------------|---------|
| **[MUST]** | **Yes** | Merge blocker. Fix **in this branch**. Introduced or worsened by this PR, or required to ship safely. |
| **[SHOULD]** | **Yes** | Fix **in this branch** before merge. Important quality, tests, consistency, or UX in touched files — same actionability as MUST, not optional. |
| **[NICE TO HAVE]** | **No** | Actionable improvement **in this branch** in touched files: naming, small refactors, extra polish. Worth doing; does not block Approve. |
| **[OUT OF SCOPE]** | **No** | Real issue, but pre-existing or belongs to another feature/backlog slice — not this PR. Record so nothing is lost. |
| **[VERIFY]** | **No** | Might be a problem; one **concrete** check (command, test, scenario) — not a fix yet. |

### Scope rules

**In scope for [MUST] / [SHOULD] / [NICE TO HAVE]:**

- Files in the diff
- Tests/docs required to land the change
- Regressions **this PR introduces**

**→ [OUT OF SCOPE], not the three actionable tiers:**

- Pre-existing debt in untouched files
- Backlog items unless **this PR newly violates** them
- Work larger than this PR's stated goal

**→ [VERIFY]:** uncertainty without evidence — one concrete check; no "probably okay"

### Severity hints (this repo)

| Tier | Examples |
|------|----------|
| **MUST** | Cross-feature import; hand-edited `*.g.dart`/`*.freezed.dart`; secrets/PII in logs; `throw` across package boundary; missing error UI for new async paths; `context` after `await` without `mounted`; new behavior without tests |
| **SHOULD** | Edge-case test in touched module; l10n for new user-facing string; weak error copy in touched UI; missing `AsyncValue` error handling in changed widget |
| **NICE TO HAVE** | Missing `const` in touched subtree; rename for clarity in touched file; extract small sub-widget in file already edited; minor readability in changed lines only |

---

## Step 5 — Spot-check (when useful)

```bash
melos exec --scope=<package> -- "flutter test test/<relevant>_test.dart"
# Deep/high-risk only: make preflight
```

Record what you **actually ran** in **Verification** (checked vs unchecked). Do not list "run preflight" as a review finding unless a specific test/analyze failure was observed.

---

## Output format

**Always include every section below**, in this order. If a section has no content, write `(no items)` on its own line under the heading — **never omit a section**.

```markdown
## PR summary

<2–3 sentences: what changed, risk level, verdict>

## Files changed

| File | Change |
|------|--------|
| `path/to/file.dart` | <brief: what this file does in the PR> |

## Scope

- Commits: `N` · Files: `M` · `+additions / -deletions`
- Packages: `<package_a>`, `<package_b>`
- Type: fix | refactor | feat | docs | chore
- **Risk:** Low | Medium | High — <one line why>
- **Architecture:** OK | Concern — <one line>

## Reviewed areas

Architecture · Riverpod · Testing · … (N/A: a11y, platform, l10n)

## Strengths

- <concrete positive in touched code>

(or `(no items)`)

## Breaking changes

- `<symbol>` — <what changed>; update callers in `<file>`

(or `(no items)`)

## [MUST]

- `path/to/file.dart:42` — <single imperative task>

(or `(no items)`)

## [SHOULD]

- `path/to/file.dart:10` — <single imperative task>

(or `(no items)`)

## [NICE TO HAVE]

- `path/to/file.dart:88` — <single imperative task>

(or `(no items)`)

## [OUT OF SCOPE]

- `path/to/existing.dart:12` — <clear problem>; pre-existing; address in <area>

(or `(no items)`)

## [VERIFY]

- `path/to/file.dart:55` — Run `<command>` or add `<test>` to confirm <specific behavior>

(or `(no items)`)

## Verification

- [x] Read full diff `origin/main...HEAD`
- [x] Ran `<command>` — passed
- [ ] CI not checked locally

## Test plan

- `<command>` — <what it validates>
- Manual: <scenario> → <expected outcome>

## Counts

MUST `n` · SHOULD `n` · NICE `n` · OUT OF SCOPE `n` · VERIFY `n`

## Verdict

**Approve** | **Request changes**
```

### Section notes

| Section | Purpose |
|---------|---------|
| **Scope** | Size/shape at a glance; risk + architecture one-liners (not full depth tables) |
| **Reviewed areas** | Which `docs/REVIEW.md` domains were applied; N/A domains in parentheses |
| **Strengths** | What the PR does well — builds confidence, not adversarial-only |
| **Breaking changes** | Caller/migration impact; `(no items)` when none |
| **Verification** | What the reviewer **did** (done vs not done) — not open questions |
| **Test plan** | Concrete commands/scenarios for this PR — for author and "fix the review" |
| **Counts** | Footer scan before reading bullets |

### Bullet rules

- Format: `` `file:line` — Task `` (line optional if file-level)
- Task is **imperative**: "Add test …", "Map failure to AppFailure …", "Rename …"
- **No** subheadings per finding, **no** Issue/Fix split
- **No** duplicate bullets for the same task across sections
- **No** hedged bullets ("consider", "might", "probably okay")

### Verdict rules

- **Request changes** — any **[MUST]** or **[SHOULD]** item (not `(no items)`)
- **Approve** — **[MUST]** and **[SHOULD]** are `(no items)`; other sections may have items
- When user says "fix the review" — implement **[MUST]** and **[SHOULD]**; **[NICE TO HAVE]** if user asks to do all review items

---

## Banned output (never write)

- "Follow-up PR", "separate PR", "track in issue", "defer to later"
- "Update PR description", "add test plan to PR", Conventional Commits reminders
- "Consider …", "might want to …", "probably acceptable"
- "Run make preflight" / "ensure CI passes" without a specific observed failure
- Omitting a required section
- Hedged items with no action ("could be a problem but leave as-is") — use **[VERIFY]** or omit from actionable tiers

---

## Anti-patterns (review process)

- Reading every governance doc for a one-line fix
- Copying `docs/REVIEW.md` PR hygiene checklist into findings
- Generic "add tests" without naming file and scenario
- Inflating style nits to **[MUST]** unless CI/analyzer fails — use **[NICE TO HAVE]**
- Assuming `gh` exists
- Leaving **Verification** or **Test plan** generic when specific commands apply

---

## Quick reference

| Topic | Doc |
|-------|-----|
| Severity policy | `docs/REVIEW.md` |
| Architecture | `docs/ARCHITECTURE.md`, `docs/ROADMAP.md` § Engineering standards |
| Riverpod | `docs/STATE_MANAGEMENT.md` |
| Routes | `docs/NAVIGATION.md` |
| Tests | `docs/TESTING.md` |
| Errors | `docs/ERROR_HANDLING.md` |
