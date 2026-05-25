---
name: pr-review
description: >-
  Review pull requests for EddyScout using repository governance, architecture
  rules, and Flutter/Dart best practices. Use when reviewing a PR, triaging
  review feedback, writing review comments, or deciding if an issue blocks merge.
---

# PR Review

> Read `CONTEXT.md` and `AGENTS.md` before performing any review.
>
> Reviews must follow repository governance, architecture rules, and Flutter/Dart best practices.
>
> Canonical checklist and severity policy also live in `docs/REVIEW.md`. When this skill and `docs/REVIEW.md` disagree on severity, follow `docs/REVIEW.md` and flag the conflict.

## Review priorities

Apply scrutiny in this order:

1. Correctness
2. Architecture integrity
3. Performance
4. Lifecycle safety
5. Maintainability
6. Accessibility
7. Security
8. Long-term repository health

## When to use

- User asks for a PR review or code review on a branch/PR
- Triaging review comments or deciding merge blockers
- Pre-merge quality pass on a changeset

## Review workflow

Execute in order. Do not skip steps.

### 1. Gather change context

- Read the PR description, linked issues, and test plan.
- Inspect the full diff: `git diff <base>...HEAD` or `gh pr diff <number>`.
- List touched packages/features and classify change categories (section 1 below).
- Note CI status: `gh pr checks <number>` when a PR number is available.

### 2. Load required context

Read mandatory docs before reviewing (skim sections relevant to the diff if time-constrained, but do not skip docs whose domains appear in the diff):

| Always read | Conditional |
|-------------|-------------|
| `CONTEXT.md`, `AGENTS.md` | `docs/PLATFORMS.md` — platform-specific code |
| `docs/GOVERNANCE.md` | `docs/LOCALIZATION.md` — l10n/strings |
| `docs/ARCHITECTURE.md` | `docs/DEPENDENCIES.md` — new/changed dependencies |
| `docs/STATE_MANAGEMENT.md` | `docs/ERROR_HANDLING.md` — error/retry/offline paths |
| `docs/PERFORMANCE.md` | `docs/ANALYTICS.md` — analytics/telemetry |
| `docs/TESTING.md` | `docs/CI_CD.md` — CI/CD or workflow changes |
| `docs/SECURITY.md` | `docs/RESPONSIVENESS.md` — layout/breakpoints (with `docs/UI.md`) |
| `docs/UI.md` | `docs/THEMING.md` — theme/token changes |
| `docs/NAVIGATION.md` | |
| `docs/CODEGEN.md` | |

Use companion skills when the diff warrants deeper passes: `riverpod-usage`, `state-management`, `navigation-change`, `accessibility-review`, `security-review`, `testing`, `golden-testing`, `performance-profiling`.

### 3. Classify risk

Complete **§1 Change Risk Assessment** before line-by-line review. Higher risk → deeper scrutiny and more checklist sections.

### 4. Review against checklist

Work through **§2–§18** below. For each applicable section, verify items against the actual diff. Mark N/A only when the PR clearly does not touch that domain.

### 5. Produce structured output

Use **Review Output Format** at the end. Every finding needs: description, severity, affected file(s), reasoning, suggested fix.

### 6. Verdict

State explicitly:

- **Approve** — no MUST items; SHOULD items noted or absent
- **Request changes** — one or more MUST items
- **Comment** — no MUST items; meaningful SHOULD/NICE items only

---

## Review severity levels

### MUST

Blocking issues that would cause:

- Crashes
- Memory leaks
- Security vulnerabilities
- Architecture violations
- Broken UX
- Data corruption
- Accessibility failures
- Severe performance regressions
- CI/build failures
- Unsafe async behavior
- Lifecycle bugs
- Broken navigation
- Repository rule violations

These must be fixed before merge.

### SHOULD

Important improvements that affect:

- Maintainability
- Readability
- Consistency
- Moderate performance risks
- Technical debt
- Test quality
- Code duplication
- Scalability
- Architectural clarity

Should generally be fixed before merge unless intentionally deferred (document deferral and link a follow-up issue when deferring).

### NICE TO HAVE

Non-blocking suggestions such as:

- Stylistic consistency
- Readability improvements
- Small optimizations
- Minor refactors
- Developer experience improvements

These are optional.

---

## 1. Change risk assessment

Classify the PR risk level before reviewing.

### Change categories

Mark all that apply:

- [ ] UI-only changes
- [ ] State-management changes
- [ ] Navigation changes
- [ ] Dependency injection changes
- [ ] Networking changes
- [ ] Persistence/storage changes
- [ ] Authentication/security changes
- [ ] Platform-specific changes
- [ ] Platform channel changes
- [ ] Async lifecycle changes
- [ ] Generated code changes
- [ ] Architecture changes
- [ ] CI/CD changes
- [ ] Dependency changes
- [ ] Analytics/telemetry changes
- [ ] Performance-sensitive changes

### Risk level

- [ ] Low
- [ ] Medium
- [ ] High
- [ ] Critical

Higher-risk changes require deeper review scrutiny.

---

## 2. Architecture compliance

### Layering

- [ ] Feature follows `presentation → domain ← data` separation
- [ ] No cross-feature imports
- [ ] `domain/` has no dependencies on `data/` or `presentation/`
- [ ] Shared code lives in approved shared locations (`core`, `design_system`, etc.)
- [ ] Repository boundaries respected
- [ ] Feature ownership boundaries preserved
- [ ] No architecture drift introduced

### Dependency direction

- [ ] Dependency flow is one-directional
- [ ] No circular dependencies
- [ ] No forbidden imports
- [ ] Packages do not import from `apps/`

### Business logic

- [ ] No business logic inside widgets
- [ ] No networking inside UI layer
- [ ] No persistence logic inside presentation layer
- [ ] Side effects isolated appropriately (providers, notifiers, `ref.listen` — not `build()`)

---

## 3. Riverpod / state management review

### Provider design

- [ ] Correct provider type chosen (see `docs/STATE_MANAGEMENT.md`, `riverpod-usage` skill)
- [ ] Provider responsibilities are focused
- [ ] Providers are not overly broad
- [ ] Provider ownership boundaries respected
- [ ] No duplicated provider responsibilities

### Lifecycle

- [ ] `autoDispose` used where appropriate
- [ ] Provider invalidation scoped correctly
- [ ] Providers disposed safely
- [ ] No memory leaks from retained providers

### Async state

- [ ] `AsyncValue` fully handled
- [ ] Loading state handled
- [ ] Error state handled
- [ ] Empty state handled
- [ ] Success state handled
- [ ] Retry flows considered

### Performance

- [ ] `ref.watch` scope minimized
- [ ] `ref.select()` used where appropriate
- [ ] Large rebuild scopes avoided

---

## 4. Widget & UI review

### Widget design

- [ ] Widgets have single responsibility
- [ ] Large widgets extracted into subwidgets
- [ ] Widget composition preferred over inheritance
- [ ] Widgets remain readable and maintainable

### Build safety

- [ ] No async work in `build()`
- [ ] No expensive computation in `build()`
- [ ] No side effects in `build()`
- [ ] No unnecessary object creation in `build()`

### Immutability

- [ ] `const` constructors used where possible
- [ ] Widgets immutable where appropriate
- [ ] Mutable shared state avoided

### Design system

- [ ] Material 3 tokens used
- [ ] No hardcoded colors
- [ ] No hardcoded spacing
- [ ] No duplicated styles
- [ ] Typography tokens used (`Theme.of(context).textTheme`)
- [ ] Semantic colors used

### Responsiveness

- [ ] Layout adapts to screen sizes
- [ ] Tablet layouts considered
- [ ] Landscape layouts considered
- [ ] Overflow risks checked
- [ ] Text scaling supported

---

## 5. Performance review

### Rebuild isolation

- [ ] Rebuild scope minimized
- [ ] Expensive widgets isolated
- [ ] Large lists isolated from unrelated state
- [ ] Animations isolated appropriately

### Rendering

- [ ] `ListView.builder` or slivers used for large lists
- [ ] Images sized appropriately
- [ ] Images cached appropriately (`CachedNetworkImage` where remote)
- [ ] Lazy loading used where appropriate

### Performance safety

- [ ] No unnecessary rebuild triggers
- [ ] No synchronous heavy work on UI thread
- [ ] No excessive widget nesting
- [ ] No repeated API calls during rebuilds

### Memory

- [ ] Controllers disposed correctly
- [ ] Streams disposed correctly
- [ ] Timers cleaned up
- [ ] Subscriptions cancelled

---

## 6. Lifecycle & async safety review

### Lifecycle safety

- [ ] No `BuildContext` usage after async gaps without `mounted` check
- [ ] `mounted` checks used correctly
- [ ] Async callbacks lifecycle-safe
- [ ] No state updates after disposal

### Async architecture

- [ ] Duplicate requests avoided
- [ ] Request cancellation considered (`CancelToken` with dio)
- [ ] Retry strategy implemented correctly (backoff, max retries, no retry on 4xx except 429)
- [ ] Timeout strategy appropriate
- [ ] Stale state prevention considered
- [ ] Pagination resilient
- [ ] Offline handling considered

---

## 7. Navigation review

- [ ] Routes typed correctly
- [ ] Route ownership respected (feature routes; assembly in `packages/routing/`)
- [ ] Auth guards applied correctly
- [ ] Deeplinks validated
- [ ] Navigation side effects isolated
- [ ] Nested navigation handled correctly
- [ ] Navigation state not duplicated
- [ ] go_router only — no ad-hoc `Navigator.push` outside router config

---

## 8. Error handling review

- [ ] Loading states graceful
- [ ] Error states user-friendly (no raw exception strings)
- [ ] Empty states handled
- [ ] Partial failure states handled
- [ ] Retry UX exists where appropriate
- [ ] Destructive actions confirmed
- [ ] Errors logged appropriately (no PII/tokens)
- [ ] Failures degrade gracefully
- [ ] `Result<T, AppFailure>` used at package boundaries — no uncaught exceptions across packages

---

## 9. Accessibility review

### Semantics

- [ ] Semantic labels provided
- [ ] Semantic hierarchy correct
- [ ] Screen reader support verified

### Interaction

- [ ] Touch targets ≥ 48×48 dp
- [ ] Keyboard navigation supported (web)
- [ ] Focus order logical
- [ ] Focus states visible

### Visual accessibility

- [ ] Contrast ratios acceptable (WCAG AA)
- [ ] Text scales correctly
- [ ] Reduced motion considerations respected
- [ ] Information not conveyed by color alone

---

## 10. Security review

### Secrets & sensitive data

- [ ] No hardcoded secrets
- [ ] No API keys committed
- [ ] PII not logged
- [ ] Sensitive data redacted from logs

### Network security

- [ ] HTTPS enforced
- [ ] Certificate validation respected
- [ ] Unsafe WebView usage avoided
- [ ] Deeplinks validated safely

### Dependency security

- [ ] Dependencies reviewed
- [ ] No suspicious packages introduced
- [ ] Transitive dependency risk acceptable

---

## 11. Code generation review

- [ ] Generated files not manually edited (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`)
- [ ] Codegen rerun successfully (`make gen` / `make gen-check`)
- [ ] No stale generated artifacts
- [ ] Freezed models valid
- [ ] Serialization generated correctly
- [ ] Generated providers updated

---

## 12. Dependency review

### New dependencies

- [ ] Dependency justified
- [ ] Existing solution insufficient
- [ ] Package actively maintained
- [ ] Package ecosystem reputation acceptable
- [ ] License compatible (see `docs/DEPENDENCIES.md`)
- [ ] Binary size impact acceptable
- [ ] Transitive dependency impact acceptable
- [ ] Human approval obtained for new dependencies (per `AGENTS.md`)

### Versioning

- [ ] Version constraints appropriate
- [ ] No unnecessary dependency upgrades
- [ ] Dependency conflicts avoided

---

## 13. Testing review

### Coverage

- [ ] Coverage thresholds met (`tooling/coverage.yaml`, `docs/TESTING.md`)
- [ ] Critical paths covered
- [ ] Edge cases covered
- [ ] Failure cases covered

### Test quality

- [ ] Tests deterministic
- [ ] No real network usage
- [ ] No real timers unless required
- [ ] Assertions meaningful
- [ ] Tests implementation-independent
- [ ] `mocktail` only — not `mockito`

### Widget testing

- [ ] Widget tests for pages/complex widgets
- [ ] Widget tests resilient
- [ ] Golden tests stable (design system components)
- [ ] Async UI flows tested (`pump` / `pumpAndSettle`)

---

## 14. Platform review

- [ ] Android behavior considered
- [ ] iOS behavior considered
- [ ] Web compatibility considered
- [ ] Desktop compatibility considered (if applicable)
- [ ] Permissions handled correctly and justified
- [ ] Conditional imports safe
- [ ] Platform-specific code isolated behind abstractions

---

## 15. Analytics & logging review

### Analytics

- [ ] Analytics events emitted correctly
- [ ] Naming conventions followed
- [ ] Duplicate events avoided
- [ ] PII not tracked

### Logging

- [ ] Logs structured appropriately
- [ ] Debug/`print` removed from production paths
- [ ] Sensitive data redacted
- [ ] Logging volume reasonable

---

## 16. CI/CD & tooling review

- [ ] CI passes
- [ ] Analyzer passes cleanly (`make analyze`)
- [ ] Formatting passes (`make format`)
- [ ] Tests pass (`make test`)
- [ ] Coverage checks pass (`make coverage`)
- [ ] Codegen verification passes (`make gen-check`)
- [ ] Build verification passes when relevant
- [ ] No skipped tests without justification
- [ ] PR hygiene per `docs/REVIEW.md` (description, scope, Conventional Commits)

---

## 17. AI-assisted development review

### AI safety

- [ ] No hallucinated APIs used
- [ ] No hallucinated packages used
- [ ] Generated code reviewed carefully
- [ ] Repository conventions followed
- [ ] Existing patterns reused appropriately

### Complexity review

- [ ] No unnecessary abstractions
- [ ] No overengineering introduced
- [ ] Boilerplate reasonable
- [ ] Solution complexity justified

### Consistency

- [ ] Matches repository architecture
- [ ] Matches repository naming conventions
- [ ] Matches repository patterns
- [ ] Matches repository state management conventions

---

## 18. Final reviewer questions

### Correctness

- [ ] Does this change work correctly?
- [ ] Are edge cases handled?
- [ ] Could this crash?

### Architecture

- [ ] Does this preserve architecture integrity?
- [ ] Does this introduce technical debt?
- [ ] Will this scale maintainably?

### Performance

- [ ] Could this introduce jank?
- [ ] Could this increase rebuild scope?
- [ ] Could this create memory leaks?

### Maintainability

- [ ] Would another developer understand this easily?
- [ ] Is the abstraction level appropriate?
- [ ] Is complexity justified?

### User experience

- [ ] Are loading/error states polished?
- [ ] Is accessibility preserved?
- [ ] Is the UX resilient?

Also ask (from `docs/REVIEW.md`):

- Would I deploy this to production now?
- If this breaks at 2 AM, will error messages help diagnosis?
- Is this the simplest solution that meets requirements?

---

## Review output format

Structure review findings exactly as:

```markdown
## Summary

<1–3 sentences: what changed, risk level, overall verdict>

## Change risk

- Categories: …
- Risk level: Low | Medium | High | Critical

## MUST

Blocking issues that must be fixed before merge.

### <short title>

- **Files:** `path/to/file.dart`, …
- **Reasoning:** …
- **Suggested fix:** …

## SHOULD

Important improvements strongly recommended before merge.

### <short title>

- **Files:** …
- **Reasoning:** …
- **Suggested fix:** …

## NICE TO HAVE

Optional improvements and suggestions.

### <short title>

- **Files:** …
- **Reasoning:** …
- **Suggested fix:** …

## Checklist notes

Brief note on sections marked N/A and any gaps not verifiable from the diff alone.

## Verdict

Approve | Request changes | Comment
```

Each finding must include: issue description, severity, affected file(s), reasoning, suggested fix.

Do not omit MUST items when they exist. Do not inflate severity — style-only items belong in NICE TO HAVE unless linters/governance already classify them higher.
