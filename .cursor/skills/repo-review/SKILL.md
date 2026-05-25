---
name: repo-review
description: >-
  Review the entire EddyScout repository against governance, architecture
  rules, and Flutter/Dart best practices. Use when auditing the full
  codebase for compliance, preparing for a release, or performing a
  comprehensive quality assessment.
---

# Repository Review

> Read `CONTEXT.md` and `AGENTS.md` before performing any review.
>
> Reviews must follow repository governance, architecture rules, and Flutter/Dart best practices.
>
> Canonical checklist and severity policy also live in `docs/REVIEW.md`. When this skill and `docs/REVIEW.md` disagree on severity, follow `docs/REVIEW.md` and flag the conflict.

## Scope

This skill reviews the **entire repository**, not a single PR. Every file in the codebase must be evaluated against the criteria below. Do NOT skip files, packages, or directories. If a section does not apply to a specific file, mark it N/A for that file but still acknowledge it was checked.

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

- Full codebase audit
- Release readiness assessment
- Architecture compliance sweep
- Periodic quality gate review
- Onboarding new team members (verify baseline quality)
- Post-migration or post-refactor validation

## Review workflow

Execute in order. Do not skip steps. Do not skip files.

### 1. Enumerate all packages and files

- List every package in `apps/` and `packages/` (including nested feature packages under `packages/features/`).
- For each package, enumerate all Dart source files under `lib/` and all test files under `test/`.
- Track coverage: every file must appear in at least one checklist section's findings.
- **DO NOT SKIP ANY FILES.** If a file has no issues, note it as reviewed with no findings.

### 2. Load required context

Read ALL mandatory docs before reviewing — this is a full repo review, so all docs are relevant:

| Always read | Always read |
|-------------|-------------|
| `CONTEXT.md` | `docs/PLATFORMS.md` |
| `AGENTS.md` | `docs/LOCALIZATION.md` |
| `docs/GOVERNANCE.md` | `docs/DEPENDENCIES.md` |
| `docs/ARCHITECTURE.md` | `docs/ERROR_HANDLING.md` |
| `docs/STATE_MANAGEMENT.md` | `docs/ANALYTICS.md` |
| `docs/PERFORMANCE.md` | `docs/CI_CD.md` |
| `docs/TESTING.md` | `docs/RESPONSIVENESS.md` |
| `docs/SECURITY.md` | `docs/THEMING.md` |
| `docs/UI.md` | `docs/ACCESSIBILITY.md` |
| `docs/NAVIGATION.md` | `docs/NETWORKING.md` |
| `docs/CODEGEN.md` | `docs/COMMENTS.md` |

Use companion skills for deeper passes in specific domains: `riverpod-usage`, `state-management`, `navigation-change`, `accessibility-review`, `security-review`, `testing`, `golden-testing`, `performance-profiling`, `form-creation`, `platform-specific`, `responsive-ui-validation`.

### 3. Classify repository risk areas

Before file-by-file review, identify high-risk areas in the repo:

- Packages with the most external dependencies
- Features with the most complex state management
- Areas with the lowest test coverage
- Recently changed files (higher risk of regressions)
- Files with the most lines of code (higher complexity risk)

### 4. Review every file against checklist

Work through **§1–§18** below. For each section, review **every applicable file** in the repository. Do not mark a section complete until all files have been checked.

### 5. Produce structured output

Use **Review Output Format** at the end. Every finding needs: description, severity, affected file(s), reasoning, suggested fix.

### 6. Coverage verification

Before finalizing, verify that every Dart source file in the repository has been reviewed. List any files that were not covered and explain why.

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

These must be fixed.

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

Should generally be fixed. Document deferral and link a follow-up issue when deferring.

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

- [ ] Every feature follows `presentation → domain ← data` separation
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

- [ ] All routes typed correctly
- [ ] Route ownership respected everywhere (feature routes; assembly in `packages/routing/`)
- [ ] Auth guards applied correctly on all protected routes
- [ ] All deeplinks validated
- [ ] Navigation side effects isolated everywhere
- [ ] Nested navigation handled correctly everywhere
- [ ] Navigation state not duplicated anywhere
- [ ] go_router only — no ad-hoc `Navigator.push` anywhere outside router config

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
- [ ] `Result<T, AppFailure>` used at all package boundaries — no uncaught exceptions across packages

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

## Review output format

Structure review findings exactly as:

```markdown
## Summary

<1–3 sentences: overall repository health, risk areas, verdict>

## Repository risk profile

- Total packages reviewed: …
- Total files reviewed: …
- High-risk packages: …
- Risk level: Low | Medium | High | Critical

## MUST

Blocking issues that must be fixed.

### <short title>

- **Files:** `path/to/file.dart`, …
- **Reasoning:** …
- **Suggested fix:** …

## SHOULD

Important improvements strongly recommended.

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

## Coverage verification

- Files reviewed: <count>
- Files not reviewed: <count and list if any>
- Packages reviewed: <list>

## Checklist notes

Brief note on sections marked N/A and any gaps.

## Verdict

- Repository health: Healthy | Needs attention | Critical issues
- Production readiness: Ready | Conditional | Not ready
- Recommended follow-ups: …
```

Each finding must include: issue description, severity, affected file(s), reasoning, suggested fix.

Do not omit MUST items when they exist. Do not inflate severity — style-only items belong in NICE TO HAVE unless linters/governance already classify them higher.

**CRITICAL: Do not skip any files. Every Dart source file in the repository must be reviewed. Track and report coverage in the output.**
