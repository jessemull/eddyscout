---
name: repo-review
description: >-
  Review the entire EddyScout repository: fixed-section task lists, same
  severity tiers as pr-review. Use for full audits, release readiness,
  or post-migration validation.
---

# Repository Review

**Severity definitions:** `docs/REVIEW.md` (when MUST vs SHOULD vs NICE is ambiguous).

**Output shape:** same rules as `.cursor/skills/pr-review/SKILL.md` — flat `` `file:line` — task `` bullets, fixed sections, `(no items)` when empty. **Scope differs:** this skill reviews the **entire repo**, not a single PR diff.

**Governance:** read `CONTEXT.md` + `AGENTS.md` + all mandatory `docs/` (full audit — not diff-scoped).

---

## What repo review is (and is not)

**Review:** every package, source file, and test against governance and architecture — findings are repo-wide compliance gaps.

**Not review:** PR description quality, commit message format, merge process, or re-litigating **planned** backlog work already tracked in `docs/ARCHITECTURE_BACKLOG.md` / `docs/ROADMAP.md` (use **[OUT OF SCOPE]** for those).

**vs `pr-review`:** use `pr-review` for branch/PR review; use this skill for full-repo audits. Same bullet format and tiers; repo review adds **Coverage** and uses **Ready / Needs work** verdict.

---

## Principles

1. **Repo-wide** — enumerate every package and Dart file; do not skip directories.
2. **Risk-prioritized** — deep scrutiny on high-risk packages first; still cover all files.
3. **One bullet = one task** — imperative, fixable; no Issue/Reasoning/Suggested-fix blocks.
4. **Checklists are internal** — work through `docs/REVIEW.md` + **§1–§18** below; **never paste** checklist tables into output.
5. **Fixed sections** — always render all output sections; use `(no items)` when empty.
6. **No hedging in actionable tiers** — no "consider", "probably fine", "optional" in MUST/SHOULD/NICE bullets.

**Review priorities (internal ordering):** correctness → architecture → performance → lifecycle → maintainability → accessibility → security → long-term health.

---

## When to use

- Full codebase audit
- Release readiness assessment
- Architecture compliance sweep (e.g. after wave 2/3 merges)
- Post-migration or post-refactor validation
- Periodic quality gate review

---

## Step 1 — Enumerate scope

```bash
# Packages
ls apps/ packages/features/ 2>/dev/null
find apps packages -path '*/lib/*.dart' -o -path '*/test/*.dart' | sort

# Optional baseline
git log -20 --oneline
make analyze   # or note "not run" in Verification
```

Collect for output:

- Package count, source file count, test file count
- High-risk packages (deps, state complexity, low coverage, recent churn, large files)
- **Reviewed areas:** domains from Step 4 that were applied; N/A domains in parentheses

**Do not skip files.** Files with no issues still count as reviewed — report counts in **Coverage**.

---

## Step 2 — Load context

Read ALL mandatory docs — full repo review, all domains apply:

| Always read | Always read |
|-------------|-------------|
| `CONTEXT.md` | `docs/PLATFORMS.md` |
| `AGENTS.md` | `docs/LOCALIZATION.md` |
| `docs/GOVERNANCE.md` | `docs/DEPENDENCIES.md` |
| `docs/ARCHITECTURE.md` | `docs/ERROR_HANDLING.md` |
| `docs/ARCHITECTURE_BACKLOG.md` | `docs/ANALYTICS.md` |
| `docs/STATE_MANAGEMENT.md` | `docs/CI_CD.md` |
| `docs/TESTING.md` | `docs/RESPONSIVENESS.md` |
| `docs/SECURITY.md` | `docs/THEMING.md` |
| `docs/UI.md` | `docs/ACCESSIBILITY.md` |
| `docs/NAVIGATION.md` | `docs/NETWORKING.md` |
| `docs/CODEGEN.md` | `docs/COMMENTS.md` |

Companion skills for deep passes: `riverpod-usage`, `security-review`, `accessibility-review`, `testing`, `golden-testing`, `navigation-change`, `performance-profiling`.

**Skip for reviewers:** `docs/REVIEW.md` § PR hygiene — not a repo audit finding.

---

## Step 3 — Classify repository risk (internal)

For each package, note risk tags: UI, state, navigation, networking, persistence, security, platform, codegen, architecture, dependencies.

Assign package risk: Low | Medium | High | Critical. Fold summary into output **Scope** — do not dump per-package tables unless the user asks.

---

## Step 4 — Review against checklists (internal)

Work through **§1–§18** below and `docs/REVIEW.md` by domain. Every applicable file must be checked before the section is complete.

Findings become output bullets in Step 5 — not copied checklist rows.

---

## Step 5 — Classify each finding

Assign every finding to exactly one bucket:

| Bucket | Blocks "Ready"? | Meaning |
|--------|-----------------|---------|
| **[MUST]** | **Yes** | Repo-wide blocker: crash, security, architecture violation, CI failure, unsafe async, broken UX in shipped paths. |
| **[SHOULD]** | **Yes** | Important fix before calling the repo healthy — tests, consistency, error handling, maintainability. Same actionability as MUST. |
| **[NICE TO HAVE]** | **No** | Actionable polish in existing files: naming, `const`, small refactors. Does not block Ready. |
| **[OUT OF SCOPE]** | **No** | Known gap **already scheduled** in `ARCHITECTURE_BACKLOG.md` / `ROADMAP.md` (e.g. wave 3 screen migration to feature `presentation/`) — not a new violation. Record so audit does not re-file planned work. |
| **[VERIFY]** | **No** | Uncertainty; one **concrete** command or scenario — not a fix yet. |

### Severity hints (this repo)

| Tier | Examples |
|------|----------|
| **MUST** | Cross-feature import; hand-edited `*.g.dart`; secrets in source; `throw` across package boundary; missing error UI on user-facing async paths; `context` after `await` without `mounted` |
| **SHOULD** | Missing test for critical path; l10n gap on user-facing string; `AsyncValue` error not handled; stale doc contradicting code |
| **NICE TO HAVE** | Missing `const` in widget subtree; readability rename; minor duplication in same file |
| **OUT OF SCOPE** | UI still in `apps/eddyscout/lib/screens/` while wave 3 (Bucket B) is open — scheduled migration, not a new layering violation |

---

## Step 6 — Spot-check (when useful)

```bash
make preflight          # release readiness
make coverage           # threshold check
melos exec --scope=<package> -- "flutter test"
```

Record what you **actually ran** in **Verification**. Do not list "run preflight" as a finding unless it failed with a specific error.

---

## Internal checklists (§1–§18)

> **Do not paste these sections into review output.** Use them as the audit rubric; emit flat task bullets only.

## 1. Change risk assessment

Classify the repository risk profile.

### Risk areas

For each package, mark all that apply:

- [ ] UI-only code
- [ ] State-management code
- [ ] Navigation code
- [ ] Dependency injection code
- [ ] Networking code
- [ ] Persistence/storage code
- [ ] Authentication/security code
- [ ] Platform-specific code
- [ ] Platform channel code
- [ ] Async lifecycle code
- [ ] Generated code
- [ ] Architecture-critical code
- [ ] CI/CD configuration
- [ ] Dependency definitions
- [ ] Analytics/telemetry code
- [ ] Performance-sensitive code

### Package risk summary

For each package, assign a risk level:

- [ ] Low
- [ ] Medium
- [ ] High
- [ ] Critical

Higher-risk packages require deeper review scrutiny.

---

## 2. Architecture compliance

Review **every file** for architecture compliance.

### Layering

- [ ] Every feature follows `presentation → domain ← data` separation (partial today — UI in app shell; wave 3 migration → **[OUT OF SCOPE]** if tracked in backlog, not **[MUST]**)
- [ ] No cross-feature imports exist anywhere in the codebase
- [ ] `domain/` has no dependencies on `data/` or `presentation/` in any package
- [ ] Shared code lives in approved shared locations (`core`, `design_system`, etc.)
- [ ] Repository boundaries respected across all packages
- [ ] Feature ownership boundaries preserved in all features
- [ ] No architecture drift exists

### Dependency direction

- [ ] Dependency flow is one-directional in every package
- [ ] No circular dependencies exist
- [ ] No forbidden imports exist
- [ ] No package under `packages/` imports from `apps/`
- [ ] No feature package imports from sibling feature packages

### Business logic

- [ ] No business logic inside widgets in any file
- [ ] No networking inside UI layer in any file
- [ ] No persistence logic inside presentation layer in any file
- [ ] Side effects isolated appropriately everywhere (providers, notifiers, `ref.listen` — not `build()`)

---

## 3. Riverpod / state management review

Review **every provider** in the codebase.

### Provider design

- [ ] Correct provider type chosen everywhere (see `docs/STATE_MANAGEMENT.md`, `riverpod-usage` skill)
- [ ] All provider responsibilities are focused
- [ ] No providers are overly broad
- [ ] Provider ownership boundaries respected in all packages
- [ ] No duplicated provider responsibilities across the codebase

### Lifecycle

- [ ] `autoDispose` used where appropriate in all providers
- [ ] Provider invalidation scoped correctly everywhere
- [ ] All providers disposed safely
- [ ] No memory leaks from retained providers

### Async state

- [ ] `AsyncValue` fully handled in every async provider consumer
- [ ] Loading state handled in every async UI
- [ ] Error state handled in every async UI
- [ ] Empty state handled in every data-driven UI
- [ ] Success state handled correctly everywhere
- [ ] Retry flows considered where appropriate

### Performance

- [ ] `ref.watch` scope minimized everywhere
- [ ] `ref.select()` used where appropriate
- [ ] Large rebuild scopes avoided across the codebase

---

## 4. Widget & UI review

Review **every widget file** in the codebase.

### Widget design

- [ ] All widgets have single responsibility
- [ ] All large widgets extracted into subwidgets
- [ ] Widget composition preferred over inheritance everywhere
- [ ] All widgets remain readable and maintainable

### Build safety

- [ ] No async work in `build()` anywhere
- [ ] No expensive computation in `build()` anywhere
- [ ] No side effects in `build()` anywhere
- [ ] No unnecessary object creation in `build()` anywhere

### Immutability

- [ ] `const` constructors used where possible in all widgets
- [ ] All widgets immutable where appropriate
- [ ] Mutable shared state avoided everywhere

### Design system

- [ ] Material 3 tokens used everywhere
- [ ] No hardcoded colors in any file
- [ ] No hardcoded spacing in any file
- [ ] No duplicated styles across the codebase
- [ ] Typography tokens used everywhere (`Theme.of(context).textTheme`)
- [ ] Semantic colors used everywhere

### Responsiveness

- [ ] All layouts adapt to screen sizes
- [ ] Tablet layouts considered for all screens
- [ ] Landscape layouts considered for all screens
- [ ] Overflow risks checked in all layouts
- [ ] Text scaling supported in all widgets

---

## 5. Performance review

Review **every file** for performance concerns.

### Rebuild isolation

- [ ] Rebuild scope minimized everywhere
- [ ] Expensive widgets isolated across all screens
- [ ] Large lists isolated from unrelated state
- [ ] Animations isolated appropriately

### Rendering

- [ ] `ListView.builder` or slivers used for all large lists
- [ ] All images sized appropriately
- [ ] All images cached appropriately (`CachedNetworkImage` where remote)
- [ ] Lazy loading used where appropriate

### Performance safety

- [ ] No unnecessary rebuild triggers anywhere
- [ ] No synchronous heavy work on UI thread anywhere
- [ ] No excessive widget nesting anywhere
- [ ] No repeated API calls during rebuilds anywhere

### Memory

- [ ] All controllers disposed correctly
- [ ] All streams disposed correctly
- [ ] All timers cleaned up
- [ ] All subscriptions cancelled

---

## 6. Lifecycle & async safety review

Review **every async operation** in the codebase.

### Lifecycle safety

- [ ] No `BuildContext` usage after async gaps without `mounted` check anywhere
- [ ] `mounted` checks used correctly everywhere
- [ ] All async callbacks lifecycle-safe
- [ ] No state updates after disposal anywhere

### Async architecture

- [ ] Duplicate requests avoided everywhere
- [ ] Request cancellation considered everywhere (`CancelToken` with dio)
- [ ] Retry strategy implemented correctly everywhere (backoff, max retries, no retry on 4xx except 429)
- [ ] Timeout strategy appropriate everywhere
- [ ] Stale state prevention considered everywhere
- [ ] Pagination resilient where used
- [ ] Offline handling considered where appropriate

---

## 7. Navigation review

Review **every route and navigation call** in the codebase.

- [ ] All routes typed correctly (`go_router_builder` in `apps/eddyscout/lib/routing/app_routes.dart`)
- [ ] Router assembly in `packages/routing/` (`goRouterProvider`); app supplies `$appRoutes` and launch validation overrides
- [ ] Redirects correct: Mapbox token gate, web map placeholder, invalid launch id → map (session auth guards deferred until auth feature)
- [ ] All deeplinks validated
- [ ] Navigation side effects isolated everywhere
- [ ] Nested navigation handled correctly everywhere
- [ ] Navigation state not duplicated anywhere
- [ ] go_router only — no ad-hoc `Navigator.push` outside router config

---

## 8. Error handling review

Review **every error path** in the codebase.

- [ ] All loading states graceful
- [ ] All error states user-friendly (no raw exception strings anywhere)
- [ ] All empty states handled
- [ ] Partial failure states handled where applicable
- [ ] Retry UX exists where appropriate
- [ ] Destructive actions confirmed everywhere
- [ ] Errors logged appropriately everywhere (no PII/tokens)
- [ ] All failures degrade gracefully
- [ ] `Result<T, AppFailure>` at package I/O boundaries where adopted; no **new** raw `throw` across boundaries (full migration tracked in `ARCHITECTURE_BACKLOG.md` A2)

---

## 9. Accessibility review

Review **every user-facing widget** in the codebase.

### Semantics

- [ ] Semantic labels provided on all interactive elements
- [ ] Semantic hierarchy correct across all screens
- [ ] Screen reader support verified for all screens

### Interaction

- [ ] All touch targets ≥ 48×48 dp
- [ ] Keyboard navigation supported on web
- [ ] Focus order logical on all screens
- [ ] Focus states visible on all interactive elements

### Visual accessibility

- [ ] Contrast ratios acceptable everywhere (WCAG AA)
- [ ] Text scales correctly in all widgets
- [ ] Reduced motion considerations respected
- [ ] Information not conveyed by color alone anywhere

---

## 10. Security review

Review **every file** for security concerns.

### Secrets & sensitive data

- [ ] No hardcoded secrets anywhere in the codebase
- [ ] No API keys committed anywhere
- [ ] PII not logged anywhere
- [ ] Sensitive data redacted from all logs

### Network security

- [ ] HTTPS enforced on all endpoints
- [ ] Certificate validation respected everywhere
- [ ] Unsafe WebView usage avoided
- [ ] All deeplinks validated safely

### Dependency security

- [ ] All dependencies reviewed
- [ ] No suspicious packages in the dependency tree
- [ ] Transitive dependency risk acceptable

---

## 11. Code generation review

Review **every generated file and its source** in the codebase.

- [ ] No generated files manually edited (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`)
- [ ] Codegen rerun successfully (`make gen` / `make gen-check`)
- [ ] No stale generated artifacts anywhere
- [ ] All freezed models valid
- [ ] All serialization generated correctly
- [ ] All generated providers up to date

---

## 12. Dependency review

Review **every dependency** in all `pubspec.yaml` files.

### Dependencies

- [ ] Every dependency justified
- [ ] No redundant dependencies
- [ ] All packages actively maintained
- [ ] All package ecosystem reputations acceptable
- [ ] All licenses compatible (see `docs/DEPENDENCIES.md`)
- [ ] Binary size impact acceptable
- [ ] Transitive dependency impact acceptable
- [ ] Human approval obtained for all dependencies (per `AGENTS.md`)

### Versioning

- [ ] All version constraints appropriate
- [ ] No unnecessary dependency upgrades
- [ ] No dependency conflicts

---

## 13. Testing review

Review **every test file** and verify coverage for **every source file**.

### Coverage

- [ ] Coverage thresholds met for all packages (`tooling/coverage.yaml`, `docs/TESTING.md`)
- [ ] All critical paths covered
- [ ] All edge cases covered
- [ ] All failure cases covered
- [ ] Every source file has a corresponding test file

### Test quality

- [ ] All tests deterministic
- [ ] No real network usage in any test
- [ ] No real timers unless required
- [ ] All assertions meaningful
- [ ] All tests implementation-independent
- [ ] `mocktail` only — not `mockito`

### Widget testing

- [ ] Widget tests exist for all pages and complex widgets
- [ ] All widget tests resilient
- [ ] Golden tests stable (design system components)
- [ ] All async UI flows tested (`pump` / `pumpAndSettle`)

---

## 14. Platform review

Review **every platform-specific file and configuration**.

- [ ] Android behavior considered for all features
- [ ] iOS behavior considered for all features
- [ ] Web compatibility considered for all features
- [ ] Desktop compatibility considered where applicable
- [ ] All permissions handled correctly and justified
- [ ] All conditional imports safe
- [ ] All platform-specific code isolated behind abstractions

---

## 15. Analytics & logging review

Review **every analytics event and log statement** in the codebase.

### Analytics

- [ ] All analytics events emitted correctly
- [ ] Naming conventions followed everywhere
- [ ] No duplicate events anywhere
- [ ] PII not tracked anywhere

### Logging

- [ ] All logs structured appropriately
- [ ] No debug/`print` statements in production paths
- [ ] Sensitive data redacted from all logs
- [ ] Logging volume reasonable

---

## 16. CI/CD & tooling review

Review **all CI/CD configuration and tooling**.

- [ ] CI passes
- [ ] Analyzer passes cleanly (`make analyze`)
- [ ] Formatting passes (`make format`)
- [ ] Tests pass (`make test`)
- [ ] Coverage checks pass (`make coverage`)
- [ ] Codegen verification passes (`make gen-check`)
- [ ] Build verification passes
- [ ] No skipped tests without justification
- [ ] Repository hygiene per `docs/REVIEW.md`

---

## 17. AI-assisted development review

Review **all code** for AI-generated artifacts.

### AI safety

- [ ] No hallucinated APIs used anywhere
- [ ] No hallucinated packages used anywhere
- [ ] All generated code reviewed
- [ ] Repository conventions followed everywhere
- [ ] Existing patterns reused appropriately

### Complexity review

- [ ] No unnecessary abstractions anywhere
- [ ] No overengineering anywhere
- [ ] Boilerplate reasonable everywhere
- [ ] Solution complexity justified everywhere

### Consistency

- [ ] All code matches repository architecture
- [ ] All code matches repository naming conventions
- [ ] All code matches repository patterns
- [ ] All code matches repository state management conventions

---

## 18. Final reviewer questions

Ask these for **every package and feature** in the repository.

### Correctness

- [ ] Does every feature work correctly?
- [ ] Are all edge cases handled?
- [ ] Could any code path crash?

### Architecture

- [ ] Does the codebase preserve architecture integrity?
- [ ] Is there any technical debt that needs addressing?
- [ ] Will the codebase scale maintainably?

### Performance

- [ ] Could any code path introduce jank?
- [ ] Are there any excessive rebuild scopes?
- [ ] Are there any potential memory leaks?

### Maintainability

- [ ] Would a new developer understand this codebase easily?
- [ ] Is the abstraction level appropriate everywhere?
- [ ] Is complexity justified everywhere?

### User experience

- [ ] Are all loading/error states polished?
- [ ] Is accessibility preserved across all screens?
- [ ] Is the UX resilient across all flows?

Also ask (from `docs/REVIEW.md`):

- Would I deploy this to production now?
- If this breaks at 2 AM, will error messages help diagnosis?
- Is this the simplest solution that meets requirements?

---

## Output format

**Always include every section below**, in this order. If a section has no content, write `(no items)` on its own line — **never omit a section**.

Same bullet rules as `pr-review`: `` `file:line` — <imperative task> ``.

```markdown
## Repo summary

<2–3 sentences: overall health, top risk areas, verdict>

## Scope

- Packages: `N` · Source files: `M` · Test files: `T`
- High-risk packages: `<name>`, …
- **Risk:** Low | Medium | High | Critical — <one line>
- **Architecture:** OK | Concern — <one line vs target in ARCHITECTURE.md>

## Reviewed areas

Architecture · Riverpod · Testing · … (N/A: analytics, platform, …)

## Strengths

- <concrete positive pattern in the codebase>

(or `(no items)`)

## Breaking changes

- `<symbol>` — <contract that would break external consumers>

(or `(no items)` — rare in full-repo audit; use for public API drift)

## Coverage

- Packages reviewed: `<list>` (`N`/`N`)
- Source files reviewed: `M` (`M`/`M` total)
- Test files reviewed: `T` (`T`/`T` total)
- Not reviewed: `(none)` or list with reason

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

- `path/to/file.dart:1` — <known gap>; scheduled in `ARCHITECTURE_BACKLOG.md` wave N / `ROADMAP.md` Phase X

(or `(no items)`)

## [VERIFY]

- `path/to/file.dart:55` — Run `<command>` to confirm <specific behavior>

(or `(no items)`)

## Verification

- [x] Enumerated all packages and Dart files
- [x] Read mandatory governance docs
- [x] Ran `make preflight` — passed
- [ ] Coverage thresholds not checked locally

## Test plan

- `make preflight` — full quality gate before release
- `make coverage` — per-package thresholds in `tooling/coverage.yaml`
- `<package-specific test command>` — <what it validates>

## Counts

MUST `n` · SHOULD `n` · NICE `n` · OUT OF SCOPE `n` · VERIFY `n`

## Verdict

**Ready** | **Needs work**
```

### Verdict rules

- **Needs work** — any **[MUST]** or **[SHOULD]** item (not `(no items)`)
- **Ready** — **[MUST]** and **[SHOULD]** are `(no items)`; other sections may have items
- **[OUT OF SCOPE]** backlog items do **not** block Ready if they are already tracked in `ARCHITECTURE_BACKLOG.md`

### Bullet rules

- Format: `` `file:line` — Task `` (line optional if file-level)
- Task is **imperative**: "Migrate …", "Add test …", "Map failure to AppFailure …"
- **No** subheadings per finding, **no** Files/Reasoning/Suggested-fix split
- **No** duplicate bullets across sections
- **No** hedged bullets ("consider", "might", "probably okay")

---

## Banned output (never write)

- "Follow-up PR", "separate PR", "track in issue", "defer to later" (use **[OUT OF SCOPE]** with backlog reference instead)
- "Update PR description", Conventional Commits reminders
- "Consider …", "might want to …", "probably acceptable"
- "Run make preflight" / "ensure CI passes" without a specific observed failure
- Omitting a required section
- Pasting §1–§18 checklist tables into the review

---

## Anti-patterns (review process)

- Skipping packages or files without listing them in **Coverage → Not reviewed**
- Inflating planned backlog gaps to **[MUST]** — use **[OUT OF SCOPE]** when `ARCHITECTURE_BACKLOG.md` already tracks the work
- Generic "add tests" without naming file and scenario
- Style nits as **[MUST]** unless analyzer/CI fails — use **[NICE TO HAVE]**
- Producing a different output shape than `pr-review` (this skill should feel like pr-review at repo scale)

---

## Quick reference

| Topic | Doc |
|-------|-----|
| PR review (same output rules) | `.cursor/skills/pr-review/SKILL.md` |
| Severity policy | `docs/REVIEW.md` |
| Platform waves | `docs/ARCHITECTURE_BACKLOG.md` |
| Product phases | `docs/ROADMAP.md` |
| Target vs today | `docs/ARCHITECTURE.md` § Current implementation status |
| Tests | `docs/TESTING.md` |
