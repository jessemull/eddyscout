# Navigation

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **NAVIGATION.md** > inline comments.
>
> **AI agents — read this file when:** adding a route, implementing navigation, setting up route guards, configuring deep links, or reviewing navigation-related code.

---

## go_router as sole navigation solution

All navigation uses go_router. No exceptions.

### Banned alternatives

| Pattern | Why it's banned |
|---------|----------------|
| `Navigator.push` / `Navigator.pop` | go_router manages the navigation stack |
| `Navigator.of(context)` | Use `context.go()`, `context.push()`, `context.pop()` |
| `MaterialPageRoute` construction | Routes are declared in go_router config |
| Custom `RouteFactory` | go_router handles route resolution |
| `Navigator 1.0` API | go_router is Navigator 2.0 based |

### Acceptable exception

`Navigator.pop` is acceptable inside dialogs and bottom sheets that are not full routes (they sit on top of the routing stack, not within it). Even here, prefer `context.pop()` if available.

---

## Typed routing requirements

### Use `go_router_builder` for type-safe routes

Define routes as annotated classes that generate type-safe extensions:

```dart
@TypedGoRoute<LaunchDetailRoute>(path: RoutePaths.launchDetail)
class LaunchDetailRoute extends GoRouteData {
  const LaunchDetailRoute({required this.launchId});
  final String launchId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LaunchDetailScreen(launchId: launchId);
  }
}
```

Path strings live in `packages/routing/lib/src/route_paths.dart` as `RoutePaths` constants so redirect logic in the routing package stays aligned with typed routes in the app shell.

### Benefits

- Compile-time route parameter safety (no string typos)
- Autocomplete for route navigation
- Refactor-safe route changes
- Generated `.gr.dart` files verified by CI

### Navigation with typed routes

```dart
// GOOD: type-safe navigation
const LaunchDetailRoute(launchId: 'willamette-park').go(context);

// BAD: string-based navigation
context.go('/launch/willamette-park');
```

String-based navigation is acceptable only in tests or when navigating to external/dynamic URLs.

---

## Deep linking support

### Requirements

1. Every screen with meaningful content must be accessible via a deep link (URL path).
2. Deep link URLs should be human-readable and stable: `/launch/willamette-park`, not `/screen/3?id=42`.
3. The app must handle deep links from cold start (app not running) and warm start (app in background).
4. Invalid deep links redirect to a safe default route (home/map screen), not a crash.

### Configuration

- Android: `AndroidManifest.xml` intent filters for the app's URL scheme.
- iOS: `Info.plist` associated domains or custom URL scheme.
- go_router handles incoming URLs and maps them to the correct route.

### Security

Deep link parameters are untrusted input. Validate and sanitize before use. See `SECURITY.md`.

---

## Auth guard patterns

When authentication is added, route guards belong in `packages/routing/lib/src/app_redirect.dart` (or a successor module), composed by `goRouterProvider`. Auth state should be read via `ref` inside `goRouterProvider` when the redirect callback needs reactive auth checks.

Example redirect shape (future auth):

```dart
GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isLoginRoute = state.matchedLocation == RoutePaths.login;

    if (!isLoggedIn && !isLoginRoute) return RoutePaths.login;
    if (isLoggedIn && isLoginRoute) return RoutePaths.map;
    return null; // no redirect
  },
  routes: [ ... ],
);
```

### Rules

1. **Auth guards are declarative** — defined in the router redirect, not imperatively in widgets.
2. **Guards check auth state via Riverpod** — `ref.read(authProvider)` or `ref.watch` in a `GoRouter` provider.
3. **Unauthenticated users are redirected, not shown an error.** The redirect preserves the intended destination for post-login return.
4. **Public routes** (map, launch list) do not require auth. Auth is only for write operations (reports, saved trips) when identity is introduced.

---

## Nested navigation rules

### When to use nested navigation

- Tab-based layouts where each tab maintains its own navigation stack (e.g., map tab, profile tab).
- Modal flows that have internal navigation (e.g., multi-step report submission).

### Implementation

Use `ShellRoute` or `StatefulShellRoute` for nested navigation:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, child) => AppShell(child: child),
  branches: [
    StatefulShellBranch(routes: [mapRoutes]),
    StatefulShellBranch(routes: [profileRoutes]),
  ],
);
```

### Rules

1. **Each branch owns its own route tree.** No cross-branch route dependencies.
2. **Shell routes handle the scaffold.** Individual screens don't independently create `Scaffold` with bottom nav.
3. **Deep links into nested routes must work.** Test that `/profile/settings` lands on the profile tab with settings pushed.

---

## Route ownership boundaries

Router assembly lives in `packages/routing/`. Typed route classes that bind to app screens stay in the app shell until feature packages own their routes.

### Structure (current)

```
packages/routing/
├── lib/src/route_paths.dart         # RoutePaths — canonical path strings
├── lib/src/app_redirect.dart        # initialAppLocation, resolveAppRedirect
├── lib/src/go_router_provider.dart  # routesProvider, isKnownLaunchIdProvider, goRouterProvider
└── lib/src/router_provider.dart     # createRouter factory

apps/eddyscout/lib/routing/
├── app_routes.dart                  # @TypedGoRoute GoRouteData + screen binding
└── app_routes.g.dart                # generated $appRoutes

apps/eddyscout/lib/main.dart         # ProviderScope override for routesProvider
```

### Rules

1. **Path constants** — add or change paths in `RoutePaths` first; reference them from `@TypedGoRoute` annotations in the app.
2. **Typed routes** — `GoRouteData` subclasses in `apps/eddyscout/lib/routing/app_routes.dart` bind paths to app screens.
3. **Router assembly** — `goRouterProvider` in `packages/routing/` composes `GoRouter` with redirects; the app supplies `$appRoutes` via `routesProvider` and launch validation via `isKnownLaunchIdProvider` overrides in `ProviderScope`.
4. **Cross-feature navigation** — a feature must not import another feature's route classes; use path strings or shared types in `packages/core/` when needed.

### Target (incremental)

Feature packages will eventually declare their own `GoRouteData` classes under `packages/features/<name>/`. The routing package will compose feature route lists; the app override pattern remains until all routes migrate.

---

## App integration

The composition root wires typed routes into the shared router:

```dart
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';

runApp(
  ProviderScope(
    overrides: [
      routesProvider.overrideWithValue($appRoutes),
      isKnownLaunchIdProvider.overrideWithValue(
        (launchId) => findLaunchPointById(launchId) != null,
      ),
      // ... other app overrides
    ],
    child: const EddyScoutApp(),
  ),
);

class EddyScoutApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(routerConfig: router, ...);
  }
}
```

`routesProvider` and `isKnownLaunchIdProvider` **must** be overridden before `goRouterProvider` is read; otherwise an `UnimplementedError` is thrown at runtime.

`mapboxAccessToken` is exported from `eddyscout_routing` for Mapbox SDK initialization in `main.dart`.

---

## Navigation testing

### What to test

1. **Route resolution:** given a path, the correct screen renders (app widget/integration tests).
2. **Typed route generation:** route `.location` produces the expected path string (`apps/eddyscout/test/routing/`).
3. **Redirects:** platform, token, and invalid-parameter redirects (`packages/routing/test/`).
4. **Deep links:** cold-start navigation to a deep link renders the correct screen.
5. **Parameterized routes:** route parameters are correctly parsed and passed to screens.
6. **Unknown routes:** unrecognized paths redirect to the fallback route.

### Package vs app tests

| Location | Scope |
|----------|-------|
| `packages/routing/test/go_router_provider_test.dart` | `goRouterProvider`, `initialAppLocation` |
| `packages/routing/test/router_provider_test.dart` | `createRouter` factory |
| `apps/eddyscout/test/routing/app_routes_test.dart` | Typed route `.location` encoding |
| `apps/eddyscout/integration_test/` | End-to-end navigation smoke |

### Testing approach

```dart
testWidgets('launch detail route renders correct launch', (tester) async {
  final router = GoRouter(
    initialLocation: '/launch/willamette-park',
    routes: [...testRoutes],
  );
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router),
  );
  expect(find.text('Willamette Park'), findsOneWidget);
});
```

Use `ProviderScope` overrides to inject mock auth state for guard tests.

---

## Redirect patterns

### Common redirects

| Scenario | Redirect |
|----------|----------|
| Unauthenticated user accessing protected route | → `/login?redirect=<original>` |
| Authenticated user accessing login page | → `/` (home) |
| Onboarding incomplete | → `/onboarding` |
| Feature flag disabled | → `/` with optional snackbar |
| Invalid route parameter | → parent route or `/` |

### Rules

1. **Redirects are defined in the router**, not in individual screens.
2. **Preserve the user's intent** — store the original destination and return after auth/onboarding.
3. **Avoid redirect chains** — a redirect should not trigger another redirect. If it does, the logic is too complex; simplify the guard conditions.
4. **Log unexpected redirects** for debugging (without logging sensitive route params).
