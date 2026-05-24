# PR Review Framework

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **REVIEW.md** > inline comments.
>
> **AI agents — read this file when:** reviewing a PR, writing review comments, triaging review feedback, or deciding whether an issue is blocking.

---

## Severity tiers

Every review comment must be tagged with a severity tier. This removes ambiguity about what blocks merge.

### MUST (blocking)

The PR **cannot merge** until these are resolved. These represent correctness, safety, or architectural violations.

- Architecture violations (wrong dependency direction, business logic in widgets, circular imports)
- Security issues (hardcoded secrets, PII in logs, missing input validation)
- Crash-inducing bugs (null dereference without guard, unhandled exceptions in critical paths)
- Data loss risks (unguarded destructive operations, missing migration steps)
- Governance violations (breaking non-negotiable constraints from `GOVERNANCE.md`)
- Type safety violations (`dynamic` misuse, force-unwrap without justification)
- Missing error state handling in UI (`AsyncValue` without `.error` case)

### SHOULD (significant)

Strongly recommended. May carry forward with a linked tracking issue, but should not become a habit.

- Performance regressions (unnecessary rebuilds, missing `const`, unbounded lists)
- Accessibility gaps (missing semantics, undersized touch targets, missing labels)
- Testing gaps (behavior change without test, missing edge cases)
- Poor error messages (raw technical errors exposed to users)
- Insufficient documentation for public API

### NICE TO HAVE (non-blocking)

Suggestions for improvement. Author may accept or decline without further discussion.

- Naming improvements
- Minor code style preferences beyond what linters enforce
- Alternative implementation approaches that are roughly equivalent
- Additional comments or documentation polish
- Minor readability improvements

---

## PR hygiene review

- [ ] PR description follows the template (What / Why / How / Testing / Checklist)
- [ ] PR is focused on a single logical change
- [ ] Commit messages follow Conventional Commits format
- [ ] No unrelated changes bundled in
- [ ] PR size is appropriate (< 400 lines preferred; large PRs justified)
- [ ] Target branch is correct
- [ ] No merge conflicts

---

## Architecture review checklist

- [ ] Dependency direction respected: `presentation → domain ← data`
- [ ] No `apps/` imports from `packages/`
- [ ] New files placed in correct feature or package directory (see `ARCHITECTURE.md`)
- [ ] Package boundaries respected — all imports are declared dependencies
- [ ] No circular dependencies introduced
- [ ] Shared code extracted to appropriate package (`core`, `design_system`, etc.)
- [ ] New feature follows feature-first directory structure
- [ ] Generated code is up to date

---

## Riverpod / state review

- [ ] Correct provider type for the use case (see `STATE_MANAGEMENT.md`)
- [ ] No business logic inside `build()` methods
- [ ] Side effects use `ref.listen` or Notifier methods, never inside `build()`
- [ ] `AsyncValue` properly handled (loading + data + error in UI)
- [ ] Provider scope is appropriate (not too broad, not too narrow)
- [ ] No mutable shared state outside Riverpod
- [ ] Providers are disposed or auto-disposed appropriately
- [ ] No duplicate providers (same data sourced from different providers)
- [ ] `select()` used to minimize rebuilds where appropriate

---

## Widget design review

- [ ] Widgets are composition-based (no deep inheritance hierarchies)
- [ ] `const` constructors used wherever possible
- [ ] Stateless unless local mutable state is genuinely needed
- [ ] ConsumerWidget (not StatefulWidget + Consumer) for provider access
- [ ] Widget file size is reasonable (< 200 lines preferred; extract sub-widgets if larger)
- [ ] Loading, error, and empty states all handled
- [ ] No business logic in widget code

---

## Rebuild / performance review

- [ ] `const` constructors used on child widgets to skip rebuilds
- [ ] `select()` used on providers to avoid rebuilding on unrelated state changes
- [ ] Large lists use `ListView.builder` or slivers (not `Column` with `List<Widget>`)
- [ ] No expensive synchronous work in `build()` methods
- [ ] Image assets are appropriately sized and cached
- [ ] Animation controllers are disposed in `dispose()`
- [ ] Streams and subscriptions are cancelled on dispose
- [ ] No repeated API calls triggered by rebuilds

---

## Accessibility review

- [ ] Interactive elements have semantic labels (`Semantics`, `semanticLabel`)
- [ ] Touch targets meet minimum size (48x48 logical pixels)
- [ ] Sufficient color contrast (4.5:1 for text, 3:1 for large text)
- [ ] Screen reader navigation order is logical
- [ ] Dynamic content changes are announced (`SemanticsService.announce`)
- [ ] Text scales appropriately (`MediaQuery.textScaleFactor` not ignored)
- [ ] No information conveyed by color alone

---

## Security review

- [ ] No hardcoded API keys, tokens, or secrets
- [ ] No PII or tokens in log statements
- [ ] User input is sanitized before use
- [ ] Network calls use HTTPS
- [ ] Platform permissions follow least privilege (no unnecessary permissions)
- [ ] Sensitive data stored via platform-secure mechanisms (Keychain / Keystore)
- [ ] Deep links are validated before navigation
- [ ] WebViews (if any) restrict JavaScript and navigation

---

## Error-state review

- [ ] Network errors handled gracefully with user-friendly messages
- [ ] Null/empty states produce meaningful UI (not blank screens)
- [ ] Parse failures don't crash — fallback to safe defaults with logging
- [ ] Timeouts are configured for network requests
- [ ] Retry logic exists where appropriate (with backoff)
- [ ] Error boundaries prevent single-feature failures from crashing the app

---

## Testing review

- [ ] New behavior has corresponding tests
- [ ] Bug fixes include regression tests
- [ ] Edge cases covered (null, empty, boundary values, error conditions)
- [ ] Tests are deterministic (no flaky timing, no real network calls)
- [ ] Mocking uses `mocktail` (not `mockito`)
- [ ] Test file naming matches source file (`foo.dart` → `foo_test.dart`)
- [ ] Tests are in the correct directory mirroring source structure
- [ ] No test-only code in production source files

---

## Platform review

- [ ] Changes tested on both Android and iOS (if applicable)
- [ ] Platform-specific code isolated behind abstractions
- [ ] New permissions declared and justified
- [ ] No platform-specific imports in shared packages
- [ ] Android `minSdkVersion` / iOS deployment target respected

---

## Localization review

- [ ] User-facing strings use localization (`AppLocalizations`)
- [ ] No hardcoded user-facing strings
- [ ] New strings added to ARB files
- [ ] Pluralization handled correctly where needed
- [ ] RTL layout considered (if supporting RTL locales)

---

## Dependency review

- [ ] New dependencies are justified (not duplicating existing capability)
- [ ] Dependency version constraints are appropriate (caret `^` preferred)
- [ ] License is compatible (MIT, BSD, Apache 2.0 preferred; no GPL in app code)
- [ ] Package is actively maintained (check pub.dev score, last publish date)
- [ ] No unnecessary transitive dependencies pulled in
- [ ] `pubspec.yaml` updated in the correct package

---

## CI review

- [ ] CI pipeline passes on the PR
- [ ] No CI steps skipped or disabled
- [ ] New CI requirements (if any) are documented
- [ ] Generated code check passes (`melos run gen:check`)

---

## Analytics / privacy review

- [ ] Analytics events are intentional and documented
- [ ] No PII captured in analytics payloads
- [ ] User consent respected for data collection
- [ ] Data retention expectations met
- [ ] Tracking follows the project's analytics strategy

---

## Final reviewer questions

Before approving, ask yourself:

1. **Would I be comfortable deploying this to production right now?**
2. **If this breaks at 2 AM, will the error messages help someone diagnose it?**
3. **Does this change make the codebase easier or harder to work in?**
4. **Are there edge cases the author might not have considered?**
5. **Is this the simplest solution that meets the requirements?**
6. **Could a new contributor understand this code in 6 months?**
