# Architecture

> **Precedence:** CONTEXT.md > GOVERNANCE.md > **ARCHITECTURE.md** > feature docs > inline comments.
>
> **AI agents — read this file when:** creating a new file or package, adding a dependency, deciding where code belongs, resolving an import, or structuring a new feature.

---

## Monorepo structure

```
eddyscout/
├── apps/
│   └── eddyscout/              # Main Flutter application (composition shell)
│       ├── lib/
│       │   ├── main.dart
│       │   ├── screens/        # Screen-level widgets + Mapbox controller
│       │   ├── routing/        # Typed go_router_builder routes (screen binding)
│       │   ├── preferences/    # App-level Riverpod wiring for persistence
│       │   └── debug/          # Debug-only utilities
│       ├── test/               # App-level tests
│       ├── assets/             # Static assets (GeoJSON, images)
│       └── (platform dirs)     # android/, ios/, web/, macos/, linux/, windows/
├── packages/
│   ├── core/                   # LaunchPoint, Result, AppFailure, typedefs
│   ├── design_system/          # Material 3 theme, tokens, shared widgets
│   ├── networking/             # Dio factory, interceptors, HTTP client
│   ├── persistence/            # Key-value and structured storage abstractions
│   ├── analytics/              # Analytics client interface
│   ├── routing/                # GoRouter provider, RoutePaths, redirect logic
│   ├── localization/           # ARB-based l10n
│   └── features/
│       ├── conditions/         # Conditions fetching, go/no-go, Firebase
│       ├── map/                # Launch catalog and map-related types
│       ├── hydro_routing/      # River-line routing on bundled hydro geometry
│       └── _TEMPLATE/          # Scaffold for new feature packages
├── tooling/                    # Shared analysis_options, build config, coverage thresholds
├── scripts/                    # Automation scripts (preflight, codegen, coverage)
├── docs/                       # Governance and project documentation
└── pubspec.yaml                # Workspace root (melos config)
```

### Directory roles

| Directory | Purpose | Who imports it |
|-----------|---------|---------------|
| `apps/eddyscout/` | Runnable application — composes packages into a product | Nothing imports apps |
| `packages/core/` | Domain models, value objects, shared constants, pure utilities | Any package or app |
| `packages/design_system/` | Theme data, shared widgets, spacing/typography tokens | App and feature code |
| `packages/networking/` | Dio instance, interceptors, base HTTP client, response types | Feature data layers |
| `packages/persistence/` | Secure storage wrapper, shared prefs abstraction | Feature data layers |
| `packages/analytics/` | Analytics event abstraction, provider adapters | App and feature code |
| `packages/routing/` | GoRouter assembly, `RoutePaths`, platform/token redirects | App composition root |
| `packages/localization/` | ARB strings, generated `AppLocalizations` | Any package or app |
| `packages/features/*` | Feature packages with `presentation/domain/data` layers | App imports barrels |
| `tooling/` | Custom lint rules, build helpers, codegen scripts | Dev-time only |
| `scripts/` | `preflight.sh`, `codegen.sh`, `coverage.sh` | Dev-time only |

---

## App shell — `apps/eddyscout/lib/`

The app shell is a **composition layer**: it wires feature packages together into a runnable product. It does not contain domain logic, data access, or parsing — those live in feature packages.

| Path | Role |
|------|------|
| `main.dart` | `ProviderScope` overrides (`routesProvider`, `isKnownLaunchIdProvider`), Firebase init, `MaterialApp.router` |
| `routing/app_routes.dart` | Typed `go_router_builder` routes bound to app screens |
| `screens/map_screen.dart` | Map composition; Mapbox widget host |
| `screens/map/mapbox_map_controller.dart` | Mapbox lifecycle (`mapboxMapControllerProvider`) |
| `screens/map/map_constants.dart` | Map style / camera constants |
| `screens/map/map_planning_overlay.dart` | Route planning UI overlay |
| `screens/map/map_ui_callbacks.dart` | Map snackbar/navigation callback types (bound on map screen) |
| `screens/map_planning_provider.dart` | `routePlanningProvider` |
| `screens/map_session_provider.dart` | `mapInteractiveProvider` |
| `screens/launch_detail_screen.dart` | Launch detail page (+ `launch_detail/` parts) |
| `screens/missing_mapbox_token_screen.dart` | `--dart-define` gate |
| `screens/web_map_placeholder_screen.dart` | Web placeholder |
| `preferences/key_value_store_provider.dart` | `KeyValueStore` → persistence |
| `preferences/go_no_go_profile_provider.dart` | Skill profile Riverpod |
| `debug/map_debug_log.dart` | Debug-only map/route logging |

---

## Feature packages — `packages/features/`

Each feature is a standalone Dart package with `presentation/domain/data` layering under `lib/src/`.

### `conditions` — conditions fetching, go/no-go evaluation, Firebase

| Layer | Key files |
|-------|-----------|
| Domain | `conditions_models.dart`, `go_no_go.dart`, `go_no_go_thresholds.dart`, `condition_reports_repository_provider.dart`, `condition_reports_refresh_token_provider.dart` |
| Data | `conditions_service.dart`, `conditions_provider.dart`, `parsing/*.dart`, `firebase/*.dart`, `repositories/go_no_go_profile_repository.dart` |
| Presentation | `launch_reports_digest_provider.dart` |

### `map` — launch catalog and map-related types

| Layer | Key files |
|-------|-----------|
| Data | `launch_points.dart` (static catalog), `launch_providers.dart` |

Domain models (`LaunchPoint`, `LaunchFlowBands`) live in `packages/core/lib/src/launch_models.dart`. The barrel re-exports them.

### `hydro_routing` — river-line routing on bundled hydro geometry

| Layer | Key files |
|-------|-----------|
| Domain | `route_result.dart` (`@freezed` success/failure union) |
| Data | `geodesy.dart`, `river_geojson.dart`, `river_graph.dart`, `river_route_planner.dart`, `river_route_planner_provider.dart` |

---

## Architecture pattern: feature-first + layered

### Layer responsibilities

```
┌─────────────────────────────────────────┐
│           Presentation layer            │
│  Screens, widgets, ConsumerWidgets      │
│  Reads providers, dispatches actions    │
│  No business logic, no direct I/O      │
├─────────────────────────────────────────┤
│             Domain layer                │
│  Models (freezed), value objects        │
│  Business rules (Go/No-Go evaluator)   │
│  Service interfaces                    │
│  Pure functions and transformations     │
├─────────────────────────────────────────┤
│              Data layer                 │
│  API clients (dio), parsers            │
│  Repository implementations            │
│  Local storage (drift, prefs)          │
│  Firebase callables                    │
│  Platform adapters                     │
└─────────────────────────────────────────┘
```

### Dependency direction

```
presentation → domain ← data
```

- **Presentation depends on domain.** Screens import models, read providers backed by domain types.
- **Data depends on domain.** Repositories implement domain interfaces, return domain models.
- **Domain depends on neither.** Domain models and business rules are pure — no Flutter imports, no I/O, no platform code.

This is enforced by package boundaries: `packages/core/` (domain) has no dependency on `packages/networking/` (data) or `packages/design_system/` (presentation).

---

## Current implementation status

Target architecture vs. what exists today. Cursor rules and skills reference this section so agents do not assume unfinished work is already done.

| Area | Target | Today |
|------|--------|-------|
| Feature layering | `presentation` / `domain` / `data` per feature package | Partial: UI primarily in `apps/eddyscout/lib/screens/`; `map` is mostly data; `conditions` has domain + data + one presentation provider |
| Riverpod codegen | `@riverpod` for new providers | **Partial:** conditions, map, hydro, and app shell (`preferences/`, map planning/session, mapbox controller) use `@riverpod`; **`goRouterProvider` still manual** (wave 2 A1) |
| `Result<T, AppFailure>` | Package I/O boundaries | **Done:** conditions repos, providers, and callables; hydro `riverRoutePlannerProvider` load/parse; map `launchPointByIdProvider` catalog lookup |
| Router assembly | `packages/routing/` | `goRouterProvider` in package; app supplies `$appRoutes` and launch validation via `ProviderScope` overrides |
| Auth redirects | Session/login guards when needed | Mapbox token + web platform redirects only |
| Tab / shell nav | `StatefulShellRoute` when multi-tab | Single-stack typed routes |
| Golden tests | Design system + stable layouts | Design system golden tests exist (e.g. `packages/design_system/test/goldens/app_theme_golden_test.dart`) |
| Integration tests | Critical journeys in `integration_test/` | Token gate + map → launch detail journey; CI `integration-test` job |
| Secure storage | `flutter_secure_storage` for secrets | Not in pubspecs; `persistence` uses SharedPreferences for non-sensitive prefs |
| Remote images | Sized + cached network images | No `CachedNetworkImage` usage yet |

**New code** SHOULD move toward the target column. **Existing code** MAY migrate incrementally. Full audit trail: `docs/CURSOR_CONSISTENCY_AUDIT.md`.

---

## Package boundaries and dependency rules

### Rules

1. **Packages never import from `apps/`.** The app is a consumer of packages, not the other way around.
2. **Packages declare all dependencies in their `pubspec.yaml`.** No transitive-only usage.
3. **Circular dependencies are forbidden.** If A depends on B, B must not depend on A.
4. **Core is dependency-minimal.** `packages/core/` should depend only on `dart:core`, `freezed_annotation`, `json_annotation`, and similar codegen annotations. No Flutter SDK dependency in core if avoidable.
5. **Design system depends on core (for model types) and Flutter SDK.** It must not depend on networking, persistence, or routing.
6. **Networking depends on core (for domain types) and dio.** It must not depend on Flutter SDK unless required for interceptors.
7. **Persistence depends on core (for domain types), drift, and platform packages.** It must not depend on networking.
8. **Feature packages may depend on shared packages but never on other features.** Cross-feature communication flows through `packages/core/` types or Riverpod providers in the app shell.

### Dependency graph (allowed directions)

```
apps/eddyscout
  ├── packages/core
  ├── packages/design_system       → core
  ├── packages/networking          → core
  ├── packages/persistence         → core
  ├── packages/analytics           → core
  ├── packages/routing             → flutter, flutter_riverpod, go_router
  ├── packages/localization        (standalone)
  ├── packages/features/conditions → core, networking, persistence
  ├── packages/features/map        → core
  └── packages/features/hydro_routing → core
```

---

## Where things go

### New features

Create a new package under `packages/features/`:

1. Copy `packages/features/_TEMPLATE/` to `packages/features/<feature_name>/`.
2. Rename references in `pubspec.yaml`, barrel exports, and directory names.
3. Add the package path to the root `pubspec.yaml` under `workspace:`.
4. Follow the `presentation/domain/data` layering from `_TEMPLATE/TEMPLATE.md`.

If the feature introduces **shared domain models**, those go in `packages/core/`. If it introduces **shared widgets**, those go in `packages/design_system/`.

### App-only screens

Screens that compose feature packages without introducing new domain logic live in `apps/eddyscout/lib/screens/`. Feature-specific widgets that are **not reusable** stay in the app.

### Shared widgets

`packages/design_system/lib/` — organized by widget category:

```
design_system/lib/
├── src/
│   ├── buttons/
│   ├── cards/
│   ├── indicators/
│   ├── layout/
│   └── theme/
└── design_system.dart     # barrel export
```

### State (providers and notifiers)

- **Feature-scoped providers:** `packages/features/<pkg>/lib/src/data/` or `lib/src/presentation/`
- **App-wide providers:** `apps/eddyscout/lib/preferences/` or alongside screens
- **Package-provided providers:** Each package may expose providers (e.g., `packages/networking/` could expose a `dioProvider`). These live in the package's `lib/src/` directory.

See `STATE_MANAGEMENT.md` for provider type selection and lifecycle rules.

### API clients

HTTP clients live in `packages/networking/`. Feature-specific HTTP wiring (provider creating and disposing a client) lives in the feature's data layer — e.g., `packages/features/conditions/lib/src/data/conditions_http_provider.dart`.

### Navigation

Router assembly lives in `packages/routing/` (`goRouterProvider`, `RoutePaths`, `resolveAppRedirect`). Typed routes that bind paths to app screens live in `apps/eddyscout/lib/routing/app_routes.dart`. The app wires them together in `main.dart` via `routesProvider` and `isKnownLaunchIdProvider` overrides. See `docs/NAVIGATION.md`.

### Tests

Tests live in `test/` within each package and the app:

```
apps/eddyscout/test/
├── screens/             # Widget tests for screens
├── routing/             # Unit tests for route config
├── preferences/         # Unit tests for profile providers
└── firebase/            # Unit tests for Firebase providers

packages/features/conditions/test/
├── *.dart               # Parsing, go/no-go, payload tests

packages/features/hydro_routing/test/
├── *.dart               # River graph, route planner tests

packages/features/map/test/
├── *.dart               # Launch provider tests

packages/core/test/
├── *.dart               # Result type tests

packages/routing/test/
├── app_redirect_test.dart
├── go_router_provider_test.dart
```

See `TESTING.md` for naming conventions and coverage requirements.

### Assets

`apps/eddyscout/assets/` — organized by type:

```
assets/
├── hydro/               # GeoJSON river geometries
├── images/              # App images (if any)
└── ...
```

Assets must be declared in `apps/eddyscout/pubspec.yaml` under `flutter.assets`.

### Generated code

Generated files live alongside their source files:

- `*.g.dart` — json_serializable output
- `*.freezed.dart` — freezed output
- `*.gr.dart` — go_router_builder output

Generated files **are committed** to the repository. CI verifies they are up to date via `scripts/codegen_verify.sh`.

---

## Cross-cutting concerns

### Error handling

- Use typed error classes (sealed classes or `freezed` unions), not raw exceptions.
- Every `AsyncValue` in the UI must handle `.loading`, `.data`, and `.error` states. No unhandled error states.
- Network errors surface user-friendly messages; raw HTTP errors never reach the UI.

### Logging

- Use `dart:developer` `log()` for development logging.
- Never log tokens, PII, or secrets. See `SECURITY.md`.
- Debug-only utilities live in `lib/debug/` and must be stripped or gated from release builds.

### Dependency injection

- Riverpod is the DI mechanism. No service locators, no `GetIt`, no manual singletons.
- See `STATE_MANAGEMENT.md` for provider patterns.

### Code generation

- Run `make gen` after changing any file annotated with `@freezed`, `@JsonSerializable`, `@riverpod`, or `@TypedGoRoute`.
- CI enforces generated code freshness.

### Platform-specific code

- Minimize platform-specific code. Use Flutter's platform abstractions first.
- When unavoidable, isolate platform code behind abstract interfaces in `packages/core/` with implementations in the relevant package.
- Platform permissions follow the principle of least privilege. See `SECURITY.md`.

---

## Known tech debt

- Two style rules (`prefer_constructors_over_static_methods`, `prefer_expression_function_bodies`) are suppressed in `tooling/analysis_options.feature.yaml` for feature packages.
- `dependency_overrides: source_gen: 4.2.0` in the root `pubspec.yaml` works around a `build_runner` / `analyzer` compatibility issue. Remove when upstream deps align.
- App coverage threshold is 40%. Raise as widget test coverage improves.
