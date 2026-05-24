# Testing

> **Precedence**: CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this document
>
> **AI agents**: Read this if your task involves writing tests, modifying test infrastructure, changing coverage thresholds, or setting up test fixtures.

## Philosophy

Tests are the primary safety net for autonomous AI-assisted development. Every piece of logic that can break must have a test. Tests must be deterministic, fast, and isolated.

## Required Test Types

### Unit Tests

- **Scope**: Domain logic, data transformations, use cases, repositories, utilities
- **Location**: `test/` mirroring `lib/` structure
- **Runner**: `flutter_test`
- **Mocking**: `mocktail`

Every public function in `domain/` and `data/` layers must have unit tests.

### Widget Tests

- **Scope**: Pages, complex widgets, interactive components
- **Location**: `test/` mirroring `lib/` structure
- **Runner**: `flutter_test`

Every page/screen must have widget tests covering:
- Initial render (loading state)
- Data loaded state
- Error state with retry
- Empty state
- Key user interactions

### Integration Tests

- **Scope**: Critical user flows end-to-end
- **Location**: `integration_test/`
- **Runner**: `integration_test` package

Required for:
- App startup flow
- Core navigation paths
- Authentication flows
- Data submission flows

### Golden Tests

- **Scope**: Design system components, complex layouts
- **Location**: `test/goldens/`
- **Runner**: `golden_toolkit`

Required for:
- All design system widgets
- Complex layout components
- Responsive breakpoint behavior

Optional for feature widgets.

## Coverage

Minimum thresholds are defined in `tooling/coverage.yaml`. CI fails if coverage drops below the threshold for any package.

Current thresholds:
- `eddyscout_core`: 80%
- `eddyscout_networking`: 75%
- `eddyscout_persistence`: 75%
- `eddyscout_analytics`: 70%
- `eddyscout_routing`: 70%
- `eddyscout_design_system`: 60%
- `eddyscout_localization`: 60%
- `eddyscout` (app): 40% (low due to legacy code, raise as migration progresses)

## Mocking Strategy

### Use `mocktail`

```dart
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements LaunchRepository {}
```

### Do NOT use

- `mockito` — requires codegen for null-safe mocks
- Manual mock classes — use `mocktail` `Mock` base
- Real HTTP calls — always mock network layer

### Fake Services

For complex dependencies, prefer `Fake` over `Mock`:

```dart
class FakeAnalyticsClient extends Fake implements AnalyticsClient {
  final events = <AnalyticsEvent>[];

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    events.add(event);
  }
}
```

## Deterministic Testing

- Mock ALL I/O (network, storage, platform channels)
- Use `FakeAsync` for time-dependent logic
- Use fixed test data (no random values)
- Use `TestWidgetsFlutterBinding` for widget tests
- Never use `Timer`, `Future.delayed`, or real time in tests

## Async Testing

- Always `await tester.pump()` after triggering async operations
- Use `await tester.pumpAndSettle()` only when animations are expected
- For Riverpod async providers, pump until `AsyncValue.data` is emitted
- Use `runAsync` for tests that need real async execution

## Test File Naming

```
lib/src/domain/use_cases/get_launch_points.dart
test/src/domain/use_cases/get_launch_points_test.dart
```

- Test files mirror source file paths
- Suffix: `_test.dart`
- Group tests with `group()` by method or behavior
- Use descriptive names: `'should return launch points when repository succeeds'`

## Riverpod Testing

```dart
final container = ProviderContainer(
  overrides: [
    launchRepositoryProvider.overrideWithValue(mockRepository),
  ],
);
addTearDown(container.dispose);

final result = await container.read(launchPointsProvider.future);
```

## What NOT to Test

- Generated code (*.g.dart, *.freezed.dart)
- Framework internals (Flutter rendering, GoRouter matching)
- Trivial getters/constructors with no logic
- Third-party package internals

## CI Enforcement

- `make test` runs all tests across all packages
- `make coverage` generates lcov reports
- CI fails on any test failure
- CI fails on coverage regression below threshold
