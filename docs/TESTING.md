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
- **Location**: `integration_test/` (typically under `apps/eddyscout/`)
- **Runner**: `integration_test` package

> **Current repo:** integration tests at `apps/eddyscout/integration_test/`:
> - `app_navigation_test.dart` — missing Mapbox token gate (no dart-defines)
> - `map_launch_detail_journey_test.dart` — map → launch detail → back (requires dart-defines below)
>
> CI runs both via the **Integration Test** job in `.github/workflows/ci.yml`.

**Run locally** (requires a desktop device target, e.g. `-d linux` or `-d macos`):

```bash
# Token gate (default compile — no Mapbox token)
cd apps/eddyscout
flutter test integration_test/app_navigation_test.dart -d linux

# Map → launch detail journey
flutter test integration_test/map_launch_detail_journey_test.dart -d linux \
  --dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
  --dart-define=INTEGRATION_MAP_STUB=true

# Or from repo root (Linux desktop):
make integration-test
```

CI uses `xvfb-run` with `-d linux` on Ubuntu. The journey test uses `INTEGRATION_MAP_STUB` so Mapbox platform views are replaced with a widget stub on headless CI. Navigation to launch detail mirrors production (`LaunchDetailRoute.push`) because map markers are native Mapbox annotations and are not tappable via Flutter finders.

Required for:
- App startup flow
- Core navigation paths
- Authentication flows
- Data submission flows

### Golden Tests

- **Scope**: Design system components, complex layouts
- **Location**: `test/goldens/` and/or files named `*_golden_test.dart` (both conventions allowed)
- **Runner**: `golden_toolkit`

> **Current repo:** golden tests exist (e.g. `packages/design_system/test/goldens/app_theme_golden_test.dart`).

Golden PNGs are generated on macOS and validated in the **Golden Tests** CI job (`macos-latest`). Ubuntu test jobs run `flutter test --exclude-tags golden` because font rasterization differs across platforms.

Required for:
- All design system widgets
- Complex layout components
- Responsive breakpoint behavior

Optional for feature widgets.

## Coverage

Minimum thresholds are defined in `tooling/coverage.yaml`. CI fails if coverage drops below the threshold for any package.

Current thresholds:
- `eddyscout_core`: 85%
- `eddyscout_design_system`: 85%
- `eddyscout_networking`: 85%
- `eddyscout_persistence`: 85%
- `eddyscout_analytics`: 85%
- `eddyscout_routing`: 85%
- `eddyscout_localization`: 85%
- `eddyscout_conditions`: 85%
- `eddyscout_map`: 85%
- `eddyscout_hydro_routing`: 85%
- `eddyscout` (app): 85%

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
