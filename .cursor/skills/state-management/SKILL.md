# State Management

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when designing or implementing state management for a feature.

## References

- `docs/STATE_MANAGEMENT.md` — provider rules, naming, lifecycle guidelines

## State Type Identification

| State Type | Example | Provider |
|-----------|---------|----------|
| Server/remote data | API response, user profile | `AsyncNotifierProvider` |
| Local UI state | Tab index, scroll offset | `StateProvider` / `NotifierProvider` |
| Derived/computed | Filtered list, formatted date | `Provider` |
| Real-time stream | WebSocket, Firestore | `StreamProvider` |
| Form state | Field values, validation | `NotifierProvider` |

## Checklist

### 1. Identify the State Type

- [ ] Determine if state is server, local, derived, or streaming
- [ ] Use the table above to pick the right provider type
- [ ] Prefer `@riverpod` codegen annotations

### 2. Choose Provider Type

- [ ] Simple sync value → `Provider` / `@riverpod` getter
- [ ] Async one-shot → `FutureProvider` / `@riverpod` async getter
- [ ] Async with mutations → `AsyncNotifierProvider` / `@riverpod` async class
- [ ] Stream → `StreamProvider` / `@riverpod` Stream getter
- [ ] Mutable sync state → `NotifierProvider` / `@riverpod` class

### 3. Place in the Correct Layer

- [ ] Business logic providers → `domain/` layer
- [ ] Data-fetching providers → `data/` layer
- [ ] UI-only state → `presentation/` layer
- [ ] Respect layer boundaries: no upward imports

### 4. Implement with `autoDispose`

- [ ] Default to `autoDispose` (codegen does this automatically)
- [ ] Only use `keepAlive: true` for app-global state (auth, theme)
- [ ] Use `ref.keepAlive()` for conditional keep-alive (e.g., cache window)

### 5. Handle AsyncValue States

- [ ] Always use `.when(loading:, error:, data:)` in widgets
- [ ] Show meaningful error messages, not raw exceptions
- [ ] Provide skeleton/shimmer UI during loading

### 6. Side-Effects with `ref.listen`

- [ ] Use `ref.listen` for navigation, snackbars, analytics
- [ ] Never trigger side-effects inside `build()`
- [ ] Use `ref.invalidate()` to force-refresh data

### 7. Test

- [ ] Create `ProviderContainer` with dependency overrides
- [ ] Assert state transitions: initial → loading → data/error
- [ ] Test notifier methods in isolation
- [ ] Run `make preflight`
