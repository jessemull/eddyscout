---
name: testing
description: >-
  Write, update, and debug tests for EddyScout: unit, widget, integration,
  and golden tests. Use when adding features, fixing bugs, refactoring
  logic, or validating coverage.
---

# Testing

Read the following before writing, updating, or debugging any tests:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/TESTING.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/DEPENDENCIES.md`
- `docs/PERFORMANCE.md`

Companion skills:
- `riverpod-usage` — provider testing with `ProviderContainer` and overrides
- `golden-testing` — visual regression test conventions
- `accessibility-review` — a11y assertions in widget tests
- `code-generation` — ensuring codegen output is fresh before testing
- `manual-test-steps` — human emulator/UI verification checklist after UI work

Testing is a **hard requirement for correctness, maintainability, and CI integrity**.

All code must be:
- deterministic
- isolated
- repeatable
- dependency-controlled
- environment-independent

---

# When to Use

Use this skill when:

- adding new features
- fixing bugs
- refactoring logic
- changing providers or state
- modifying UI components
- upgrading dependencies
- validating performance or behavior
- preventing regressions

---

# Core Testing Principles

## Tests Are Specifications

Tests define:
- expected behavior
- system contracts
- regression protection
- architectural guarantees

---

## Determinism Is Mandatory

Tests must NOT depend on:
- real network calls
- real time
- real storage
- external services
- system state

---

## Test Pyramid Enforcement

Prefer:
1. Unit tests (most)
2. Widget tests (medium)
3. Integration tests (few)
4. Golden tests (selective UI regression only)

---

# 1. Test Type Selection

## Decision Matrix

| Type | When | Location |
|------|------|----------|
| Unit | business logic, domain, utils | `test/` mirroring `lib/` |
| Widget | UI rendering + interaction | `test/` mirroring `lib/` |
| Integration | full app flows | `integration_test/` |
| Golden | visual regression | `test/` with `_golden_test.dart` |

### Integration test decision criteria

**Add E2E when:** new critical multi-route journey; behavior widget tests cannot cover; auth/submit/offline product slices.

**Skip E2E when:** widget tests cover the screen; domain/data-only change; duplicate of existing journey.

**Budget:** at most one new `integration_test/` file per product epic unless justified in PR.

See `docs/TESTING.md` and `docs/ROADMAP.md` § Integration test backlog.

---

## Rules

- [ ] prefer unit tests for logic-heavy code
- [ ] prefer widget tests for UI behavior
- [ ] avoid integration tests unless necessary
- [ ] use golden tests only for stable UI surfaces

---

# 2. File Structure Rules

- [ ] mirror `lib/` structure exactly in `test/`
- [ ] suffix all test files with `_test.dart`
- [ ] keep tests close to source for maintainability

Example:

```
packages/features/conditions/lib/src/data/conditions_provider.dart
packages/features/conditions/test/...   # mirrors lib/ under test/

packages/features/map/lib/src/presentation/map_planning_provider.dart
packages/features/map/test/src/presentation/map_planning_provider_test.dart
```

---

# 3. Mocking Strategy

## Standard Tooling

- [ ] use `mocktail` (preferred)
- [ ] avoid `mockito` unless required by legacy code

## Mock Rules

- [ ] mock external dependencies only
- [ ] do not mock domain logic unnecessarily
- [ ] prefer fake implementations for complex dependencies

---

## Riverpod Testing

- [ ] use `ProviderContainer` for unit tests
- [ ] use `ProviderScope(overrides: ...)` for widget tests
- [ ] override dependencies explicitly
- [ ] avoid global state leakage between tests

---

# 4. Test Design Standards

## Naming

- [ ] use descriptive test names
- [ ] describe behavior, not implementation

Examples:
- GOOD: `should return error when network request fails`
- BAD: `test login failure`

---

## Structure (AAA Pattern)

- Arrange
- Act
- Assert

---

## Grouping

- [ ] group related tests using `group()`
- [ ] group by behavior or feature, not file structure alone

---

# 5. Deterministic Testing Rules

## Forbidden in Tests

- real HTTP calls
- real timers
- real file system access
- external APIs
- non-seeded randomness

## Required Tools

- [ ] `fakeAsync` for time-based logic
- [ ] in-memory fakes for storage
- [ ] mocked HTTP clients for networking
- [ ] deterministic random seeds when needed

---

# 6. Widget Testing Rules

## Required Coverage

- [ ] rendering state (loading/data/error)
- [ ] user interactions (tap, scroll, input)
- [ ] provider integration via overrides
- [ ] responsive behavior where applicable

## Rules

- [ ] wrap widgets in required providers
- [ ] use `MaterialApp` or app shell wrapper
- [ ] ensure async UI states are pumped correctly
- [ ] avoid relying on implicit animations timing

---

# 7. Integration Testing Rules

> **Current repo:** `apps/eddyscout/integration_test/` — token gate (`app_navigation_test.dart`) and map → launch detail journey (`map_launch_detail_journey_test.dart`). CI runs via the **Integration Test** job in `.github/workflows/ci.yml` (`xvfb-run`, `-d linux`, journey dart-defines). Local: `make integration-test` (macOS on Darwin, Linux elsewhere).

## When Required

- authentication flows
- critical user journeys
- multi-screen navigation flows
- end-to-end state validation

## Rules

- [ ] run on a desktop device target (`-d linux` in CI, `-d macos` or `-d linux` locally)
- [ ] stub external services (Firebase reports, network) in harness overrides
- [ ] use compile-time dart-defines for Mapbox token and map stub where needed
- [ ] prefer localized strings via `integrationL10n(tester)` for assertions

---

# 8. Golden Testing Rules

- [ ] only for stable UI components
- [ ] include multiple device sizes
- [ ] cover loading, error, and empty states
- [ ] treat failures as regressions, not flakiness

---

# 9. Coverage Requirements

## Enforcement

- [ ] run coverage reports regularly
- [ ] ensure new code includes tests
- [ ] maintain thresholds defined in `docs/TESTING.md`

## Commands

```bash
flutter test --coverage
```

---

# 10. Performance Awareness in Tests

- [ ] avoid heavy setup in widget tests
- [ ] reuse test fixtures
- [ ] avoid unnecessary rebuild loops
- [ ] keep golden tests minimal and stable

---

# 11. Common Anti-Patterns

## MUST NOT

- [ ] test implementation details instead of behavior
- [ ] rely on real network or storage
- [ ] ignore async state handling
- [ ] duplicate production logic in tests
- [ ] skip edge cases (null, empty, error)
- [ ] create flaky timing-based tests

## SHOULD AVOID

- [ ] overly complex test setups
- [ ] excessive mocking of internal logic
- [ ] integration tests for simple logic
- [ ] brittle widget selectors

---

# 12. Validation Checklist

Before committing:

- [ ] correct test type chosen
- [ ] deterministic behavior ensured
- [ ] mocks properly isolated
- [ ] edge cases covered
- [ ] provider overrides used correctly
- [ ] coverage thresholds met
- [ ] push validation passes (`git push` hook; see `CONTEXT.md`)

Run while iterating:

```bash
make analyze
melos exec --scope=<package> -- "flutter test test/<file>_test.dart"
make preflight   # optional — local coverage only before PR
```

For UI/UX changes, also produce a manual test plan per `manual-test-steps` before PR.

---

# 13. Output Expectations

When completing testing work, provide:

## Test Coverage Summary
- what is covered
- what is not covered

## Test Strategy
- unit vs widget vs integration breakdown

## Risk Assessment
- flaky test risks
- missing edge cases

## Coverage Report Notes
- any threshold concerns