---
name: golden-testing
description: >-
  Create and maintain golden (visual regression) tests for EddyScout UI
  components. Use when validating layout stability, theme correctness,
  responsive behavior, or design system components.
---

# Golden Testing

Read the following before creating or updating golden tests:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/TESTING.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/UI.md`
- `docs/ACCESSIBILITY.md`
- `docs/PERFORMANCE.md`

Companion skills:
- `testing` — general test conventions and coverage requirements
- `accessibility-review` — verify a11y-visible layout structure in goldens
- `performance-profiling` — avoid heavy widget trees in golden tests

Golden tests are **visual regression tests**, not unit tests.

They validate:
- layout stability
- UI consistency
- theme correctness
- responsiveness
- component rendering correctness
- state rendering correctness

They do NOT replace:
- widget tests
- integration tests
- unit tests

---

## Current repo status

- `golden_toolkit` is listed in `apps/eddyscout/pubspec.yaml` dev_dependencies.
- There are **no** `*_golden_test.dart` files or committed golden PNGs yet.
- **New** design-system widgets and stable layouts SHOULD add goldens per `docs/TESTING.md` (`test/goldens/` or `*_golden_test.dart` suffix — both conventions are valid).

---

# When to Use

Use golden testing when:

- validating new UI components
- validating screen layouts
- validating design system components
- validating multiple states of a widget
- validating responsive behavior
- validating theme changes
- validating accessibility-visible layout structure

Avoid golden tests for:
- business logic
- API logic
- pure domain logic
- highly dynamic or animated content (unless explicitly controlled)

---

# Core Golden Testing Principles

## Stability First

Golden tests must be:
- deterministic
- stable across environments
- independent of network
- independent of time
- independent of randomness

Avoid:
- animations unless frozen
- live data
- external API calls
- non-deterministic rendering

---

## Intentional UI Snapshots

Every golden test must represent:
- a known state
- a meaningful UI scenario
- a stable layout contract

Each snapshot is a **UI contract**.

---

## Multi-Device Coverage

Golden tests must validate responsive design explicitly.

---

# 1. Test File Structure

## Naming Convention

- [ ] file named: `<widget_name>_golden_test.dart`
- [ ] mirrors source directory structure under `test/`

## Imports

- [ ] `golden_toolkit`
- [ ] widget under test
- [ ] required providers/mocks

---

# 2. Device Scenario Setup

Each golden test must include:

- phone
- tablet portrait
- tablet landscape

```dart
Device.phone
Device.tabletPortrait
Device.tabletLandscape
```

## Required Scenarios

Each widget must test at minimum:

- [ ] default state
- [ ] loading state
- [ ] error state (if applicable)
- [ ] empty state (if applicable)
- [ ] populated state (if applicable)

---

# 3. Test Construction Pattern

Use `DeviceBuilder` consistently:

- [ ] define scenarios explicitly
- [ ] name each scenario clearly
- [ ] avoid hidden state setup
- [ ] ensure reproducibility

Each scenario must represent a real user-visible state.

---

# 4. Required Wrappers

All golden tests must wrap widgets with:

## App Context

- [ ] `MaterialApp`
- [ ] app theme (light + dark where applicable)

## State Context

- [ ] `ProviderScope`
- [ ] provider overrides for deterministic state

## Layout Context

- [ ] `MediaQuery` (if needed)
- [ ] localization (`Localizations`) if relevant

## Navigation Context (if needed)

- [ ] router setup or mock navigation context

---

# 5. Determinism Requirements

Golden tests MUST be deterministic.

## Must Control:

- [ ] time (`DateTime.now()` mocked or frozen)
- [ ] randomness (`Random.seeded` or fixed values)
- [ ] network responses (mocked)
- [ ] animations (disabled or stabilized)
- [ ] fonts (consistent rendering environment)

---

# 6. State Management Setup

When using Riverpod:

- [ ] override providers explicitly
- [ ] avoid real API calls
- [ ] ensure predictable state trees
- [ ] avoid implicit global state

---

# 7. Generating Goldens

Run:

```bash
flutter test --update-goldens
```

## Rules:

- [ ] only run intentionally
- [ ] never run as part of normal CI flow
- [ ] always review diffs manually
- [ ] ensure visual changes are expected

---

# 8. Golden File Management

## Storage

- [ ] golden files committed to git
- [ ] stored in `/goldens` or alongside test (consistent per repo convention)
- [ ] consistent naming:

```text
<widget>_<scenario>_<platform>.png
```

## Updates

- [ ] updates must be intentional
- [ ] every change reviewed visually
- [ ] no accidental overwrites

---

# 9. CI Behavior

- [ ] CI runs `flutter test` without `--update-goldens`
- [ ] CI fails on pixel mismatch
- [ ] tolerance must be minimal and explicitly configured
- [ ] flaky golden tests are not acceptable

---

# 10. Accessibility in Golden Tests

Golden tests should visually validate accessibility constraints:

- [ ] text scaling works correctly
- [ ] contrast is visually acceptable
- [ ] focus states render correctly (if applicable)
- [ ] semantic structure indirectly validated via layout correctness

---

# 11. Performance Considerations

- [ ] avoid heavy widget trees in goldens
- [ ] avoid real image decoding where possible
- [ ] keep scenarios minimal but representative
- [ ] avoid excessive scenario duplication

---

# 12. Common Pitfalls

## MUST NOT

- [ ] include live data
- [ ] rely on network calls
- [ ] allow animations to run uncontrolled
- [ ] create non-deterministic layouts
- [ ] ignore device scaling differences
- [ ] commit unreviewed golden updates

## SHOULD AVOID

- [ ] overly large screens in a single golden
- [ ] mixing too many states in one scenario
- [ ] unstable fonts or rendering environments
- [ ] unnecessary duplication of scenarios

---

# 13. Validation Checklist

Before committing:

- [ ] test runs locally
- [ ] golden outputs reviewed visually
- [ ] no unintended diffs in `git diff`
- [ ] scenarios cover key states
- [ ] devices validated (phone/tablet)
- [ ] CI-compatible

---

# 14. Output Expectations

When creating golden tests, provide:

## Coverage Summary
- widgets covered
- states covered
- devices covered

## Determinism Strategy
- how state is mocked
- how time/async is controlled

## Risk Notes
- potential flakiness sources
- rendering sensitivity issues

## Review Notes
- expected visual changes
- any intentional deviations from baseline