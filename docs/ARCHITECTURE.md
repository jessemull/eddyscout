# Architecture

> **Precedence:** CONTEXT.md > GOVERNANCE.md > **ARCHITECTURE.md** > feature docs > inline comments.
>
> **AI agents — read this file when:** creating a new file or package, adding a dependency, deciding where code belongs, resolving an import, or structuring a new feature.

---

## Monorepo structure

```
eddyscout/
├── apps/
│   └── eddyscout/              # Main Flutter application
│       ├── lib/
│       │   ├── main.dart
│       │   ├── screens/        # Screen-level widgets
│       │   ├── routing/        # Route planner, river graph, geodesy
│       │   ├── conditions/     # Conditions service + parsing
│       │   ├── decision/       # Go/No-Go evaluator + thresholds
│       │   ├── data/           # Launch data models + static datasets
│       │   ├── firebase/       # Firebase bootstrap, callables, payloads
│       │   ├── network/        # HTTP client wrappers
│       │   ├── preferences/    # User preference persistence
│       │   └── debug/          # Debug-only utilities
│       ├── test/               # App-level tests
│       ├── assets/             # Static assets (GeoJSON, images)
│       ├── android/            # Android platform project
│       ├── ios/                # iOS platform project
│       ├── web/                # Web platform project
│       ├── macos/              # macOS platform project
│       ├── linux/              # Linux platform project
│       ├── windows/            # Windows platform project
│       ├── firebase/           # Firebase Functions + config
│       └── scripts/            # App-specific scripts
├── packages/
│   ├── core/                   # Shared domain models, utilities, constants
│   ├── design_system/          # Shared widgets, theme, typography, spacing
│   ├── networking/             # dio client, interceptors, API abstractions
│   ├── persistence/            # drift database, secure storage, prefs
│   ├── analytics/              # Analytics abstraction + providers
│   ├── routing/                # go_router config, typed routes, guards
│   └── localization/           # ARB files, generated l10n
├── tooling/                    # Build scripts, code generators, dev tools
├── scripts/                    # Monorepo-level scripts (preflight, android)
├── docs/                       # Governance and project documentation
└── pubspec.yaml                # Workspace root (melos config)
```

### Directory roles

| Directory | Purpose | Who imports it |
|-----------|---------|---------------|
| `apps/eddyscout/` | Runnable application — composes packages into a product | Nothing imports apps |
| `packages/core/` | Domain models, value objects, shared constants, pure utilities | Any package or app |
| `packages/design_system/` | Theme data, shared widgets, spacing/typography tokens | App and feature code |
| `packages/networking/` | dio instance, interceptors, base API client, response types | App data layer |
| `packages/persistence/` | drift DB, secure storage wrapper, shared prefs abstraction | App data layer |
| `packages/analytics/` | Analytics event abstraction, provider adapters | App and feature code |
| `packages/routing/` | go_router configuration, typed routes, auth guards | App composition root |
| `packages/localization/` | ARB strings, generated `AppLocalizations` | Any package or app |
| `tooling/` | Custom lint rules, build helpers, codegen scripts | Dev-time only |
| `scripts/` | `preflight.sh`, `run_android.sh`, hydro data docs | Dev-time only |

---

## Architecture pattern: feature-first + layered

Each feature in `apps/eddyscout/lib/` is organized by domain concern, and within each concern the code follows a layered architecture.

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

## Package boundaries and dependency rules

### Rules

1. **Packages never import from `apps/`.** The app is a consumer of packages, not the other way around.
2. **Packages declare all dependencies in their `pubspec.yaml`.** No transitive-only usage.
3. **Circular dependencies are forbidden.** If A depends on B, B must not depend on A.
4. **Core is dependency-minimal.** `packages/core/` should depend only on `dart:core`, `freezed_annotation`, `json_annotation`, and similar codegen annotations. No Flutter SDK dependency in core if avoidable.
5. **Design system depends on core (for model types) and Flutter SDK.** It must not depend on networking, persistence, or routing.
6. **Networking depends on core (for domain types) and dio.** It must not depend on Flutter SDK unless required for interceptors.
7. **Persistence depends on core (for domain types), drift, and platform packages.** It must not depend on networking.

### Dependency graph (allowed directions)

```
apps/eddyscout
  ├── packages/core
  ├── packages/design_system → core
  ├── packages/networking    → core
  ├── packages/persistence   → core
  ├── packages/analytics     → core
  ├── packages/routing       → core
  └── packages/localization  (standalone)
```

---

## Where things go

### New features

Add a new directory under `apps/eddyscout/lib/<feature_name>/` with internal layering:

```
lib/
└── <feature_name>/
    ├── models/           # freezed models specific to this feature
    ├── providers/        # Riverpod providers and notifiers
    ├── services/         # Business logic, data orchestration
    ├── widgets/          # Feature-specific widgets
    └── <feature>_screen.dart
```

If the feature introduces **shared domain models**, those go in `packages/core/`. If it introduces **shared widgets**, those go in `packages/design_system/`.

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

Feature-specific widgets that are **not reusable** stay in the feature directory under `apps/`.

### State (providers and notifiers)

- **Feature-scoped providers:** `apps/eddyscout/lib/<feature>/providers/`
- **App-wide providers:** `apps/eddyscout/lib/providers/` (if needed)
- **Package-provided providers:** Each package may expose providers (e.g., `packages/networking/` could expose a `dioProvider`). These live in the package's `lib/src/providers/` directory.

See `STATE_MANAGEMENT.md` for provider type selection and lifecycle rules.

### API clients

`packages/networking/lib/src/` — one client class per external API:

```
networking/lib/src/
├── clients/
│   ├── nws_client.dart
│   ├── usgs_client.dart
│   └── noaa_tides_client.dart
├── interceptors/
├── models/              # API-specific DTOs (not domain models)
└── networking.dart      # barrel export
```

HTTP clients live in `packages/networking/`; conditions HTTP wiring is in `packages/features/conditions/` (`conditions_http_provider.dart`).

### Navigation

`packages/routing/lib/` — route configuration, typed routes, guards:

```
routing/lib/src/
├── router.dart          # GoRouter instance
├── routes/              # Typed route definitions per feature
├── guards/              # Auth guards, onboarding gates
└── routing.dart         # barrel export
```

App routes are defined in `apps/eddyscout/lib/routing/` (`app_routes.dart`, `app_router_provider.dart`). Shared router assembly may move to `packages/routing/` over time.

### Tests

Tests mirror the source structure with a `test/` directory in each package and app:

```
apps/eddyscout/test/
├── screens/             # Widget tests for screens
├── decision/            # Unit tests for Go/No-Go logic
├── conditions/          # Unit tests for parsing, service
├── routing/             # Unit tests for river route planner
└── golden/              # Golden image tests

packages/core/test/
├── models/
└── utils/
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

Generated files **are committed** to the repository. CI verifies they are up to date via `melos run gen:check`.

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

- Run `melos run gen` after changing any file annotated with `@freezed`, `@JsonSerializable`, `@riverpod`, or `@TypedGoRoute`.
- CI enforces generated code freshness.

### Platform-specific code

- Minimize platform-specific code. Use Flutter's platform abstractions first.
- When unavoidable, isolate platform code behind abstract interfaces in `packages/core/` with implementations in the relevant package.
- Platform permissions follow the principle of least privilege. See `SECURITY.md`.
