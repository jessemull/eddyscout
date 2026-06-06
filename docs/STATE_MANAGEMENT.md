# State Management

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **STATE_MANAGEMENT.md** > inline comments.
>
> **AI agents — read this file when:** creating a provider, choosing a provider type, managing async state, implementing caching/invalidation, adding a notifier, or reviewing state-related code.

---

## Riverpod as sole state management

Riverpod is the **only** state management solution. No exceptions.

> **Current codebase:** Conditions, map, hydro, app-shell providers (`apps/eddyscout/lib/preferences/`, map session/planning, mapbox controller), and `packages/routing/` (`goRouterProvider` + DI tokens) use `@riverpod` codegen (see `docs/CODEGEN.md`). **New** providers SHOULD use `@riverpod` codegen per below. See `docs/ARCHITECTURE.md` § Current implementation status.

### Banned alternatives

| Package / pattern | Why it's banned |
|-------------------|----------------|
| `provider` (the package) | Superseded by Riverpod; mixing them causes confusion |
| `bloc` / `flutter_bloc` | Riverpod serves the same purpose with less boilerplate |
| `redux` / `flutter_redux` | Same reason as bloc |
| `ChangeNotifier` | Riverpod's `Notifier` is the replacement |
| `ValueNotifier` for shared state | Use Riverpod providers instead |
| `InheritedWidget` for app state | Riverpod handles this; `InheritedWidget` is only for framework-level Flutter code |
| `setState` for shared state | `setState` is for local ephemeral UI state only (e.g., animation toggle, form field focus) |
| `GetIt` / service locator | Riverpod is the DI mechanism |
| Global mutable singletons | Forbidden entirely — use providers |

---

## Provider types and when to use each

### Decision guide

| Situation | Provider type |
|-----------|--------------|
| Computed value from other providers (synchronous) | `Provider` |
| Computed value from other providers (async) | `FutureProvider` / `StreamProvider` |
| Simple immutable value (config, constant) | `Provider` |
| Async data fetch (one-shot) | `FutureProvider` (auto-dispose) |
| Async data stream (real-time) | `StreamProvider` |
| Mutable state with sync logic | `NotifierProvider` |
| Mutable state with async logic | `AsyncNotifierProvider` |
| Per-family variants (parameterized) | `.family` modifier on any of the above |
| State that should survive navigation | Non-auto-dispose or scoped via `ProviderScope` |
| State local to a screen/widget lifetime | Auto-dispose (default with `@riverpod`) |

### Code-generated providers (`@riverpod`)

Prefer code-generated providers using `riverpod_annotation` and `riverpod_generator`. Production reference: `packages/features/conditions/` (all providers migrated). Setup and `build.yaml` scope: `docs/CODEGEN.md`.

Functional family provider (async fetch):

```dart
@Riverpod(retry: disableProviderRetry)
Future<ConditionsSnapshot> conditionsSnapshot(Ref ref, LaunchPoint launch) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel('conditionsSnapshotProvider disposed'));
  final result = await ref.watch(conditionsRepositoryProvider).load(
    launch,
    cancelToken: cancelToken,
  );
  return result.when(
    success: (value) => value,
    failure: (error) => throw ConditionsLoadException(error),
  );
}
```

`disableProviderRetry` lives in `packages/features/conditions/lib/src/data/provider_retry.dart`. Do not pass inline lambdas to `@Riverpod(retry: …)` — the annotation constructor is `const`.

Sync notifier (refresh token):

```dart
@riverpod
class ConditionReportsRefreshToken extends _$ConditionReportsRefreshToken {
  @override
  int build() => 0;

  void increment() => state++;
}
```

Family notifier with session-persistent card state (use when pre-codegen used non-auto-dispose families):

```dart
@Riverpod(keepAlive: true)
class LaunchReportsDigest extends _$LaunchReportsDigest {
  @override
  LaunchReportsDigestState build(String launchId) { … }
}
```

DI token bound at the app composition root:

```dart
@Riverpod(keepAlive: true)
ConditionReportsRepository conditionReportsRepository(Ref ref) {
  throw UnimplementedError('Override in ProviderScope (see apps/eddyscout/lib/main.dart).');
}
```

---

## Provider ownership rules

1. **One provider per concern.** Don't combine unrelated state into a single provider.
2. **Providers are owned by the feature that defines the state.** The conditions provider lives in the conditions feature, not in the launch detail screen.
3. **Cross-feature dependencies** go through provider composition (`ref.watch`), not direct imports of internal state.
4. **Package-level providers** (e.g., a `dioProvider` in `packages/networking/`) expose infrastructure, not business logic.
5. **No orphan providers.** Every provider must be watched or read somewhere. Remove unused providers.

---

## State lifecycle management

### Auto-dispose (default)

Most providers should auto-dispose when all listeners are removed. This is the default behavior with `@riverpod` and prevents memory leaks.

### Keep-alive

Use `@Riverpod(keepAlive: true)` or `ref.keepAlive()` sparingly — only when the cost of re-fetching or resetting UI state exceeds the cost of keeping state in memory:

```dart
@Riverpod(keepAlive: true)
class LaunchReportsDigest extends _$LaunchReportsDigest { … }
```

Or inside a functional provider:

```dart
@riverpod
Future<LaunchList> launches(Ref ref) async {
  ref.keepAlive(); // launch list rarely changes; avoid re-fetch on navigation
  return ref.watch(launchRepositoryProvider).fetchAll();
}
```

### Manual invalidation

Use `ref.invalidate(provider)` to force a re-fetch or re-computation. Prefer this over manual state resetting.

### Dispose cleanup

In notifiers, register cleanup callbacks:

```dart
@override
GoNoGoState build() {
  ref.onDispose(() {
    // clean up timers, subscriptions, controllers
  });
  return const GoNoGoState.initial();
}
```

---

## AsyncValue conventions

### Always handle all three states

Every widget consuming an `AsyncValue` must handle loading, data, and error:

```dart
final conditionsAsync = ref.watch(conditionsSnapshotProvider(launch));
return conditionsAsync.when(
  loading: () => const ConditionsLoadingSkeleton(),
  error: (error, stack) => ConditionsErrorCard(message: _friendlyError(error)),
  data: (conditions) => ConditionsDisplay(conditions: conditions),
);
```

### No `.value!` in production code

Accessing `.value!` on an `AsyncValue` can throw if the state is loading or error. Use `.when()`, `.whenOrNull()`, or `.valueOrNull` with a fallback.

### Loading states

- Show skeleton/shimmer for initial load, not a bare `CircularProgressIndicator` (unless the context is clearly transient).
- For refresh (data already present + re-fetching), show the stale data with a subtle refresh indicator.

---

## Side-effect boundaries

### Never in `build()`

Side effects (network calls, writes, analytics events, navigation) must **never** occur inside `build()` or inside a provider's `build()` method.

```dart
// FORBIDDEN: side effect in build
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.read(analyticsProvider).logScreenView('launch_detail'); // fires on every rebuild!
  return ...;
}
```

### Where side effects belong

| Trigger | Mechanism |
|---------|-----------|
| User action (tap, submit) | Callback → `ref.read(notifier).method()` |
| State change reaction | `ref.listen()` in widget `initState` or `build` (listener, not builder) |
| Provider state change | `ref.listen()` inside another provider's `build()` (for derived effects) |
| Notifier method | Inside `Notifier` or `AsyncNotifier` methods — the primary home for side effects |

```dart
// GOOD: side effect in response to user action
onPressed: () => ref.read(conditionsNotifierProvider.notifier).refresh(launch),

// GOOD: side effect in response to state change
ref.listen(authProvider, (prev, next) {
  if (next == AuthState.loggedOut) context.go('/login');
});
```

---

## Repository integration patterns

Providers compose with repositories (data layer) through dependency injection:

```dart
@riverpod
ConditionsRepository conditionsRepository(Ref ref) {
  return ConditionsRepository(client: ref.watch(dioProvider));
}

@riverpod
Future<ConditionsSnapshot> conditions(Ref ref, LaunchPoint launch) {
  return ref.watch(conditionsRepositoryProvider).fetch(launch);
}
```

### Rules

1. Repositories are injected via providers, never instantiated directly in widgets.
2. Repository providers are typically non-auto-dispose (shared infrastructure).
3. Data-fetching providers that _use_ repositories are typically auto-dispose (per-screen lifecycle).

---

## Dependency injection via Riverpod

Riverpod is the DI container. All injectable dependencies are exposed as providers.

```dart
// Infrastructure
@riverpod
Dio dio(Ref ref) => Dio(BaseOptions(baseUrl: 'https://api.example.com'));

// Repository
@riverpod
LaunchRepository launchRepository(Ref ref) {
  return LaunchRepository(client: ref.watch(dioProvider));
}

// Feature state
@riverpod
Future<List<LaunchPoint>> launches(Ref ref) {
  return ref.watch(launchRepositoryProvider).fetchAll();
}
```

### Testing overrides

In tests, override providers with mocks or fakes:

```dart
final container = ProviderContainer(
  overrides: [
    conditionsRepositoryProvider.overrideWithValue(mockRepo),
  ],
);
```

---

## Caching expectations

### Default: auto-dispose

Most providers auto-dispose and re-fetch on next watch. This is correct for screen-scoped data.

### Cached providers

For data that is expensive to fetch and rarely changes, use `ref.keepAlive()` and consider a TTL:

```dart
@riverpod
Future<LaunchList> launches(Ref ref) async {
  ref.keepAlive();
  final link = ref.keepAlive();

  // Auto-invalidate after 5 minutes
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  return ref.watch(launchRepositoryProvider).fetchAll();
}
```

### What to cache

- Static datasets (launch list, river geometries)
- User preferences and profile
- Data that changes on the scale of minutes, not seconds

### What NOT to cache

- Real-time conditions (weather, flow) — always fetch fresh or use short TTL
- Auth tokens (managed separately in secure storage)

---

## Invalidation strategy

| Scenario | Method |
|----------|--------|
| User pulls to refresh | `ref.invalidate(provider)` |
| Background timer | Timer in provider that calls `ref.invalidateSelf()` |
| Write-then-read | After a mutation, invalidate the read provider |
| Logout / session change | Invalidate all user-scoped providers |
| Manual cache clear | `ref.invalidate()` on specific providers |

---

## Forbidden patterns

### Mutable shared state

```dart
// FORBIDDEN: global mutable variable
var currentLaunch = LaunchPoint(...); // use a provider
```

### Business logic in widgets

```dart
// FORBIDDEN: evaluation logic in a widget
Widget build(context, ref) {
  final wind = ref.watch(windProvider);
  final verdict = wind > 20 ? 'no-go' : 'go'; // this belongs in a notifier or service
  return Text(verdict);
}
```

### Uncontrolled provider nesting

```dart
// FORBIDDEN: creating providers inside build
Widget build(context, ref) {
  final provider = StateProvider((ref) => 0); // new provider every build!
  return Text('${ref.watch(provider)}');
}
```

### Duplicate providers

```dart
// FORBIDDEN: two providers fetching the same data
@riverpod Future<Weather> weatherA(Ref ref) => fetchWeather();
@riverpod Future<Weather> weatherB(Ref ref) => fetchWeather(); // duplicate
```

### Reading in build when watching is correct

```dart
// FORBIDDEN: ref.read in build (won't rebuild on change)
Widget build(context, ref) {
  final value = ref.read(someProvider); // should be ref.watch
  return Text(value);
}
```
