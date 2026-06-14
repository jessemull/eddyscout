# AGENTS.md — EddyScout

> Complete development rules and constraints for AI agents and human contributors.
> This file is the authoritative reference for all coding standards, architecture rules, and workflow requirements.

---

## Repository Overview

| Field | Value |
|-------|-------|
| **Project** | EddyScout — PNW paddling companion app |
| **Architecture** | Feature-first monorepo with presentation / domain / data layers |
| **Platforms** | Android (primary), iOS (primary), Web (secondary) |
| **Core Technologies** | Flutter (stable), Dart 3+, Riverpod, go_router, dio, freezed, Material 3 |
| **Monorepo Tool** | Melos (config in root `pubspec.yaml` under `melos:` key) |
| **Analysis** | very_good_analysis + custom_lint + dart_code_linter |
| **CI/CD** | GitHub Actions |
| **Git Hooks** | husky + Conventional Commits |

### Monorepo Structure

```
eddyscout/
├── apps/
│   └── eddyscout/              # Main Flutter application
├── packages/
│   ├── core/                   # Result type, AppFailure, typedefs
│   ├── design_system/          # Material 3 theme, tokens, shared widgets
│   ├── networking/             # Dio factory + interceptor contracts
│   ├── persistence/            # Key-value and structured storage abstractions
│   ├── analytics/              # Analytics client interface
│   ├── routing/                # go_router provider and route assembly
│   ├── localization/           # ARB-based l10n
│   └── features/               # Feature packages (conditions, map, hydro_routing)
├── tooling/                    # Shared analysis_options, build config, coverage thresholds
├── docs/                       # All governance documentation
├── scripts/                    # Automation scripts
├── .github/                    # CI workflows
├── .cursor/                    # Cursor rules and skills
├── .husky/                     # Git hooks
├── CONTEXT.md                  # Primary AI entry point
├── AGENTS.md                   # This file
├── Makefile                    # Developer commands
└── pubspec.yaml                # Root pubspec with melos config
```

---

## Development Commands

All commands are available via `make` targets in the root `Makefile`. They delegate to melos and shell scripts under `scripts/`. Targets are grouped and alphabetized within each group (see the root `Makefile`).

### Setup

| Command | Description |
|---------|-------------|
| `make bootstrap` / `./scripts/bootstrap.sh` | Initial setup — install dependencies, activate melos, bootstrap all packages |
| `make ensure-husky` | Verify/install husky hooks (required once per git worktree) |
| `make setup` | Alias for `bootstrap` |

### Quality / CI

| Command | Description |
|---------|-------------|
| `make analyze` | Run static analysis across all packages (`dart analyze --fatal-infos`) |
| `make ci` | CI-grade checks (same as preflight with stricter options) |
| `make coverage` | Run tests with coverage collection |
| `make coverage-check` | Run coverage and enforce thresholds in `tooling/coverage.yaml` |
| `make format` | Check formatting without modifying files (`dart format --set-exit-if-changed .`) |
| `make format-fix` | Fix formatting in place (`dart format .`) |
| `make gen` | Run code generation (`build_runner`, `freezed`, `json_serializable`, `drift`) |
| `make gen-check` | Verify codegen output is fresh (fails if stale) |
| `make preflight` | Full preflight: format → analyze → test → gen-check → coverage (optional; push hook covers most) |
| `make test` | Run all tests across all packages |

### Cleanup

| Command | Description |
|---------|-------------|
| `make clean` | Clean all packages (delete build dirs, `.dart_tool`, generated files) |

### Local dev

| Command | Description |
|---------|-------------|
| `make dev` | Bootstrap worktree, link `.local.env`, start Android emulator if needed, `flutter run` |
| `make kill-emulator` | Stop running Android emulators (`adb emu kill`) |
| `make run` | Run app on a connected device/emulator via `apps/eddyscout` (pass `ARGS="-d emulator-5554"` if needed) |

### Integration tests

| Command | Description |
|---------|-------------|
| `make integration-test` | Run `integration_test/` on macOS (Darwin) or Linux; journey test uses Mapbox stub dart-defines |

---

## Language & Framework Rules

### Null Safety
- Null safety is **always enabled**. The Dart SDK constraint enforces this.
- Do **not** use the `!` (null assertion) operator without a justification comment explaining why the value is guaranteed non-null at that point.
- Prefer `?.`, `??`, pattern matching, and early returns over null assertions.

### Immutability
- Prefer `final` for all local variables and fields.
- Use `const` for compile-time constants and constructors wherever the analyzer permits.
- All data models MUST use `freezed` for immutability, equality, and copyWith.

### Strict Typing
- Do **not** use `dynamic` without a justification comment.
- Enable `strict-casts`, `strict-inference`, and `strict-raw-types` in `analysis_options.yaml`.
- Use explicit type annotations on public API surfaces.

### Analyzer Policy
- **Zero warnings policy**: warnings are treated as errors in CI.
- `dart analyze --fatal-infos` must pass before any commit.
- All packages inherit from shared analysis options in `tooling/`.

### Generated Code
- **Never** edit `*.g.dart`, `*.freezed.dart`, or `*.gr.dart` files manually.
- Run `make gen` to regenerate after changing annotated source files.
- Run `make gen-check` to verify generated code is up to date.

---

## Architecture Rules

### Dependency Flow

```
presentation → domain ← data
```

- **`presentation/`** depends on **`domain/`** only.
- **`data/`** depends on **`domain/`** only.
- **`domain/`** has **NO dependencies** on `presentation/` or `data/`.
- This is the strict dependency inversion principle.

### Feature Boundaries
- Each feature lives in its own package under `packages/features/`.
- Features **MUST NOT** import from other features — ever.
- Cross-feature communication flows through shared domain contracts in `packages/core/` or via Riverpod providers.

### State Ownership
- All application state lives in **Riverpod providers**, not in widgets.
- Widgets are pure presentation: they read providers and render UI.
- State mutations happen through `Notifier` methods or provider invalidation.

### Repository Pattern
- Define **abstract repository interfaces** in `domain/`.
- Implement concrete repositories in `data/`.
- Bind implementations to interfaces via Riverpod provider overrides.

### Async Boundaries
- All I/O operations return `Future<Result<T, AppFailure>>` using the `Result` type from `packages/core/`.
- Never throw exceptions across package boundaries; wrap them in `AppFailure`.
- Presentation code uses `AsyncValue` from Riverpod to handle loading/error/data.

### Navigation Ownership
- Each feature declares its own routes as `GoRoute` definitions.
- All routes are assembled in `packages/routing/` into the app's router.
- Navigation logic stays in the routing layer; widgets call `context.go()` / `context.push()`.

---

## Performance Rules

### Rebuild Minimization
- Use `const` constructors on all widget subtrees that don't depend on dynamic data.
- Prefer `ConsumerWidget` over `ConsumerStatefulWidget` when lifecycle methods aren't needed.
- Use `ref.select()` for granular rebuilds — watch only the specific field you need.
- Split large widgets into smaller `const`-constructible sub-widgets.

### Const Constructors
- The analyzer enforces `prefer_const_constructors` and `prefer_const_declarations`.
- Use `const` on every widget, literal, and constructor where it compiles.

### Lazy Rendering
- Use `SliverList` / `SliverGrid` with builders for lists exceeding 20 items.
- Specify `itemExtent` or `prototypeItem` when all items have uniform height.
- Never nest `ScrollView` widgets without `shrinkWrap: true` and `NeverScrollableScrollPhysics`.

### Image Optimization
- Use `CachedNetworkImage` for all remote images.
- Size images to display dimensions — do not load full-resolution images for thumbnails.
- Prefer WebP format where platform support allows.

### Frame Budget
- Target: **16ms per frame** (60 fps) on standard devices.
- Target: **8ms per frame** (120 fps) on high-refresh-rate devices.
- Profile with DevTools; fix any frame that exceeds the budget.

### Forbidden in `build()`
- Network calls
- File I/O
- Heavy computation (>1ms)
- `setState` cascades (calling `setState` that triggers another `setState`)
- Provider creation or disposal

---

## State Management Rules

### Allowed
| Provider Type | Use Case |
|---------------|----------|
| `Provider` | Computed/derived values, dependency injection |
| `StateProvider` | Simple mutable state (toggle, counter) |
| `StateNotifierProvider` | Complex state with legacy StateNotifier |
| `NotifierProvider` | Complex synchronous state (preferred over StateNotifier) |
| `AsyncNotifierProvider` | Complex async state with methods |
| `FutureProvider` | One-shot async data |
| `StreamProvider` | Reactive stream data |

### Forbidden
- `Provider` package (the non-Riverpod one) — **banned**
- Redux — **banned**
- BLoC — **banned**
- Mutable global state (`static` mutable fields, singletons with mutable state) — **banned**
- `setState` for business logic — **banned** (acceptable only for local UI animation state)

### Async State
- Always use `AsyncValue` for async data in the UI.
- Handle **all three states**: `loading`, `error`, `data`.
- Never show a blank screen during loading; always show a loading indicator.
- Always show a user-friendly error message; never show raw exception strings.

### Provider Lifecycle
- Use `autoDispose` for providers tied to screen lifecycle.
- Use `keepAlive` only for expensive providers that should survive navigation.
- Explicitly invalidate providers after mutations that affect their data.

### Side Effects
- **NEVER** trigger side effects in `build()`.
- Use `ref.listen()` in `build()` only for reacting to state changes (showing snackbars, navigation).
- Use `Notifier` methods for all write operations and side effects.

### Caching
- Use `keepAlive` on providers that cache expensive computations or API results.
- Invalidate explicitly with `ref.invalidate()` after mutations.
- For time-based cache expiration, implement TTL logic in the repository layer.

---

## Async & Data Rules

### API Layering

```
DataSource → Repository → UseCase → Provider → Widget
```

| Layer | Responsibility |
|-------|---------------|
| `DataSource` | Raw API calls (dio), raw database queries (drift) |
| `Repository` | Coordinates data sources, caching, DTO→Entity mapping |
| `UseCase` | Single business operation, orchestrates repositories |
| `Provider` | Exposes use case results to the UI via Riverpod |
| `Widget` | Renders UI based on provider state |

### Retry Strategy
- **Exponential backoff**: base delay 500ms, multiplier 2x.
- **Max retries**: 3 attempts.
- **Retry only on**: 5xx server errors and network connectivity errors.
- **Do NOT retry**: 4xx client errors (except 429 Too Many Requests with Retry-After).

### Cancellation
- Use `CancelToken` with every dio request.
- Cancel in-flight requests when the widget/provider is disposed.
- Propagate cancellation through the use case and repository layers.

### Caching
- Cache API responses in the repository layer.
- Invalidate cache on mutation (create, update, delete).
- Use stale-while-revalidate for non-critical data.
- Store cache timestamps for freshness checks.

### Serialization
- All API models use `freezed` + `json_serializable`.
- DTO (Data Transfer Object) classes live in `data/`.
- Entity classes live in `domain/`.
- Mapping between DTO ↔ Entity happens in the `data/` layer only.

### Pagination
- Prefer cursor-based pagination for real-time data.
- Offset-based pagination is acceptable for static datasets.
- Always indicate hasMore / isLoadingMore state in the UI.

### Offline Handling
- Degrade gracefully: show cached data when offline.
- Display a staleness indicator when showing cached data.
- Queue write operations for retry when connectivity returns.
- Never crash or show an empty screen due to connectivity loss.

---

## Security Rules

### Secrets
- **NEVER** hardcode API keys, tokens, passwords, or secrets in source code.
- Use `--dart-define` for compile-time configuration.
- Use `flutter_secure_storage` for runtime secret storage.
- Store CI/CD secrets in GitHub Actions secrets — never in repository files.

### Secure Storage
- Sensitive data (tokens, credentials): `flutter_secure_storage` only.
- Non-sensitive preferences: `SharedPreferences` is acceptable.
- Never store PII in plain-text local storage.

### Logging
- **NEVER** log tokens, passwords, PII, or full request/response bodies in production.
- Use log levels appropriately: `debug` for development, `info`/`warning`/`error` for production.
- Strip sensitive headers (Authorization, Cookie) from logged requests.

### Dependencies
- Audit all dependencies monthly for known vulnerabilities.
- Pin dependency versions in `pubspec.yaml` (use `^` for minor version flexibility).
- No packages with known CVEs or abandoned maintenance.

### Permissions
- Request the minimum permissions necessary for functionality.
- Justify each platform permission in `docs/PLATFORMS.md`.
- Request permissions at the point of use, not at app startup.

### Network Security
- Enforce HTTPS everywhere — no HTTP connections.
- Pin certificates for sensitive endpoints (authentication, payments).
- Validate all URLs before loading in WebViews.
- Disable JavaScript in WebViews unless explicitly required.

### Deep Links
- Validate scheme and host before navigating to deep link targets.
- Never pass unvalidated deep link parameters to sensitive operations.

---

## Styling Rules

### Theme
- Use **Material 3** via `ColorScheme.fromSeed()`.
- Dark mode is **required** — all screens must support both light and dark themes.
- Theme configuration lives in `packages/design_system/`.

### Spacing Tokens

| Token | Value |
|-------|-------|
| `Spacing.xxs` | 2 |
| `Spacing.xs` | 4 |
| `Spacing.sm` | 8 |
| `Spacing.md` | 16 |
| `Spacing.lg` | 24 |
| `Spacing.xl` | 32 |
| `Spacing.xxl` | 48 |

### Typography
- Always use `Theme.of(context).textTheme` for text styles.
- **Never** hardcode `TextStyle` values (font size, weight, color).
- Custom text styles must be defined in the design system package.

### Colors
- Always use `Theme.of(context).colorScheme` or semantic color tokens.
- **Never** hardcode `Color(0xFF...)` values in feature code.
- Semantic colors are defined in `packages/design_system/`.

### Adaptive Layouts
- Use `LayoutBuilder` and `MediaQuery` for responsive designs.
- Define breakpoints in the design system package.
- Test layouts at multiple screen sizes (phone, tablet, desktop for web).

### Dark Mode
- Test every screen in both light and dark mode.
- Ensure all custom colors adapt to the current brightness.
- Use `colorScheme` surface/background colors — never hardcode white/black.

---

## Accessibility Rules

### Semantic Widgets
- Use the `Semantics` widget for all custom-drawn or non-standard components.
- Provide meaningful `label`, `hint`, and `value` properties.
- Group related elements with `MergeSemantics` where appropriate.

### Text Scaling
- Support `MediaQuery.textScaleFactor` — UI must remain usable at 2x text scale.
- Do not use fixed-height containers for text content.
- Test with large text accessibility settings enabled.

### Touch Targets
- Minimum touch target size: **48×48 logical pixels**.
- Use `MaterialTapTargetSize.padded` or explicit padding to meet this requirement.
- Avoid placing interactive elements too close together.

### Screen Reader
- All interactive elements must have semantic labels.
- Decorative images must be marked with `excludeFromSemantics: true`.
- Announce dynamic content changes with `SemanticsService.announce()`.

### Focus Management
- Implement proper focus traversal order.
- Show visible focus indicators on all interactive elements.
- Support keyboard navigation for web platform.

### Color Contrast
- Meet **WCAG AA** standards: 4.5:1 ratio for normal text, 3:1 for large text.
- Do not rely on color alone to convey information.
- Test with color blindness simulation tools.

---

## Testing Rules

### Requirements
- **Unit tests**: required for all domain and data layer logic.
- **Widget tests**: required for all pages and complex widgets.
- **Integration tests**: required for critical user journeys.
- Every new file must have a corresponding test file.

### Coverage
- Per-package minimum coverage thresholds are defined in `tooling/coverage.yaml`.
- Coverage is checked in CI; PRs below the threshold are blocked.

### Mocking
- Use **mocktail** only — not mockito.
- Mock all external dependencies (network, storage, platform channels).
- Use `ProviderContainer` overrides for provider-level testing.

### Determinism
- No flaky tests. All tests must be deterministic.
- Mock all I/O: network, file system, platform channels, clocks.
- Use `fakeAsync` and fake clocks for time-dependent logic.
- Never use real timers, real network calls, or real file system in unit tests.

### Async Testing
- Always use `pump()` / `pumpAndSettle()` in widget tests.
- Never use real `Future.delayed` or real `Timer` in tests.
- Use `runAsync` only when testing real async behavior is unavoidable.

### Golden Tests
- **Required** for all design system components.
- **Optional** for feature widgets (recommended for complex layouts).
- Golden files live alongside test files with `.png` extension.
- Update goldens with `flutter test --update-goldens`.

### File Naming
- Test files mirror source file paths with `_test.dart` suffix.
- Example: `lib/src/result.dart` → `test/src/result_test.dart`.
- Test directories mirror `lib/` structure exactly.

---

## File Conventions

### Naming
| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case` | `app_failure.dart` |
| Classes | `PascalCase` | `AppFailure` |
| Variables / functions | `camelCase` | `getUserProfile` |
| Constants | `camelCase` | `defaultTimeout` |
| Enum values | `camelCase` | `connectionTimeout` |
| Private members | `_camelCase` | `_fetchData` |

### Feature Structure

```
packages/features/<feature_name>/
├── lib/
│   └── src/
│       ├── presentation/       # Widgets, pages, view models
│       ├── domain/             # Entities, use cases, repository contracts
│       └── data/               # Repository implementations, DTOs, data sources
├── test/
│   └── src/
│       ├── presentation/
│       ├── domain/
│       └── data/
├── pubspec.yaml
└── analysis_options.yaml
```

### Generated Files
- `*.g.dart` — json_serializable output
- `*.freezed.dart` — freezed output
- `*.gr.dart` — auto_route output (if applicable)
- These files are committed to version control but **never manually edited**.

### Asset Naming
- Use `snake_case` for all asset file names.
- Use descriptive names: `launch_icon_light.webp`, not `icon1.webp`.
- Organize assets by type: `assets/images/`, `assets/hydro/`, `assets/icons/`.

---

## Comment Policy

See `docs/COMMENTS.md` for the complete policy.

**Summary**: comments are a maintenance cost. Write self-documenting code first. Add comments only when:

- **Intent is non-obvious**: the *why* behind a decision that the code alone cannot convey.
- **Architecture decisions**: trade-offs, alternatives considered, rationale.
- **Security constraints**: why a particular approach is security-critical.
- **Platform quirks**: workarounds for platform-specific bugs or limitations.
- **Performance trade-offs**: why a less readable approach was chosen for performance.

Do **not** write comments that restate what the code does. If the code needs a comment to explain *what* it does, refactor the code to be clearer instead.

---

## Forbidden Patterns

The following patterns are **explicitly banned**. AI agents and human contributors must not introduce them.

| Pattern | Why It's Banned | Alternative |
|---------|----------------|-------------|
| Business logic in widgets | Violates separation of concerns | Move to providers / use cases |
| Mutable shared state | Race conditions, unpredictable behavior | Use Riverpod providers |
| Async work in `build()` | Causes rebuilds, memory leaks | Use `FutureProvider` / `AsyncNotifier` |
| `context` after async gap | Context may be invalid after `await` | Use `ref` instead, or check `mounted` |
| Editing generated files | Changes will be overwritten | Run `make gen` instead |
| God widgets (>300 lines) | Unreadable, untestable | Extract sub-widgets |
| Duplicated networking logic | Maintenance burden, inconsistency | Use repository pattern |
| `dynamic` typing abuse | Defeats type safety | Enable `strict-casts` |
| `Provider` package | We use Riverpod | Use Riverpod equivalents |
| `setState` for business logic | State belongs in providers | Use Riverpod |
| Nested `ScrollView`s (raw) | Scroll conflicts, layout errors | Use `shrinkWrap` + `NeverScrollableScrollPhysics` |
| `FutureBuilder` / `StreamBuilder` | Inconsistent error/loading handling | Use Riverpod `AsyncValue` |
| `print()` in production code | No log levels, no control | Use a structured logger |

---

## AI Assistant Rules

### Mandatory

- **READ** `CONTEXT.md` before starting any work.
- **ENSURE** husky hooks in worktrees: `make ensure-husky` once per worktree (see `CONTEXT.md` § Husky in worktrees).
- **PUSH** to validate — `git push` runs the full gate via husky; do **not** run `make preflight` before push unless you need local coverage. Use scoped tests + `make analyze` while iterating.
- **EXPLAIN** architectural decisions in the PR description.
- **TEST** every new file — no untested code may be submitted.
- **FORMAT** all changes with `dart format` before committing.
- **USE** Conventional Commits format: `type(scope): description`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`
  - Scope: package or feature name (e.g., `core`, `networking`, `map`)

### Prohibited

- **DO NOT** add dependencies without human approval.
- **DO NOT** modify CI workflows (`.github/`) without human approval.
- **DO NOT** change governance documents (`CONTEXT.md`, `AGENTS.md`, `docs/GOVERNANCE.md`) without human approval.
- **DO NOT** modify generated files (`*.g.dart`, `*.freezed.dart`) manually.
- **DO NOT** introduce any Forbidden Pattern listed above.
- **DO NOT** disable lint rules without a justification comment and human approval.
- **DO NOT** skip tests or reduce coverage thresholds.

### PR Requirements

Every pull request must:

1. Pass push validation (husky on `git push`) and CI (coverage + goldens). Run `make preflight` locally only when verifying coverage before PR.
2. Include a description explaining *what* changed and *why*.
3. Reference the related issue or task.
4. Include tests for all new or changed logic.
5. Not reduce test coverage below the threshold in `tooling/coverage.yaml`.
6. Follow Conventional Commits for the commit message.
7. Be scoped to a single concern — no mixed refactors and features.
