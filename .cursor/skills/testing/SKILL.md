# Testing

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when writing new tests or updating existing test suites.

## References

- `docs/TESTING.md` — test strategy, coverage requirements, naming conventions

## Test Type Decision

| Type | When | Location |
|------|------|----------|
| Unit | Domain logic, use cases, utilities | `test/` mirroring `lib/` |
| Widget | Screen rendering, user interaction | `test/` mirroring `lib/` |
| Integration | Full feature flows with real widgets | `integration_test/` |
| Golden | Visual regression for UI components | `test/` with `_golden_test.dart` suffix |

## Checklist

### 1. Determine Test Type

- [ ] Use the matrix above to select the right test type
- [ ] Prefer unit tests for pure logic, widget tests for UI

### 2. Create Test File

- [ ] Mirror the source file path: `lib/src/domain/foo.dart` → `test/src/domain/foo_test.dart`
- [ ] Use `_test.dart` suffix for all test files

### 3. Set Up Mocks

- [ ] Use `mocktail` for mocking (not `mockito`)
- [ ] Create mock classes: `class MockFooRepo extends Mock implements FooRepo {}`
- [ ] Use `ProviderScope.overrides` for widget tests with Riverpod
- [ ] Use `ProviderContainer` with overrides for unit-testing providers

### 4. Write Descriptive Test Names

- [ ] Group related tests with `group()`
- [ ] Use descriptive names: `'should return error when network fails'`
- [ ] Test edge cases: null, empty, boundary values, error states

### 5. Ensure Deterministic Tests

- [ ] No real network calls — mock all HTTP with `mocktail`
- [ ] No real timers — use `fakeAsync` or `FakeTimer`
- [ ] No file system access — use in-memory fakes
- [ ] Seed random data for reproducibility

### 6. Run with Coverage

```bash
flutter test --coverage
```

- [ ] Verify coverage meets thresholds from `docs/TESTING.md`
- [ ] Run `make preflight` to confirm all gates pass
