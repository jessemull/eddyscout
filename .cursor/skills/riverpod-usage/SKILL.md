# Riverpod Usage

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when creating, consuming, or refactoring Riverpod providers.

## References

- `docs/STATE_MANAGEMENT.md` — provider guidelines, naming, lifecycle rules

## Provider Type Decision Matrix

| Need | Provider Type |
|------|--------------|
| Computed / derived value | `Provider` / `@riverpod` getter |
| Async fetch (no mutation) | `FutureProvider` / `@riverpod` async getter |
| Real-time stream | `StreamProvider` / `@riverpod` Stream getter |
| Mutable state with methods | `NotifierProvider` / `@riverpod` class |
| Async mutable state | `AsyncNotifierProvider` / `@riverpod` async class |

## Checklist

### 1. Choose the Right Provider Type

- [ ] Use the matrix above to select the correct provider
- [ ] Prefer `@riverpod` codegen annotation over hand-written providers

### 2. Place in the Correct Layer

- [ ] Domain logic providers → `domain/` or feature-level provider file
- [ ] Data-fetching providers → `data/` layer
- [ ] UI-only state (scroll position, tab index) → `presentation/` layer
- [ ] Never import `presentation/` from `domain/` or `data/`

### 3. Use `autoDispose`

- [ ] Default to `autoDispose` (codegen does this by default)
- [ ] Only keep alive (`@Riverpod(keepAlive: true)`) for truly global state
- [ ] Use `ref.keepAlive()` inside the provider if conditional keep-alive is needed

### 4. Handle `AsyncValue` Correctly

- [ ] Always handle `.when(loading:, error:, data:)` — never assume data
- [ ] Use `.valueOrNull` only when a fallback is acceptable
- [ ] Show user-facing errors, not raw exceptions

### 5. Side-Effects

- [ ] Use `ref.listen` for side-effects (navigation, snackbars)
- [ ] Never perform side-effects inside `build()` of a widget
- [ ] Use `ref.invalidate()` to force refresh, not manual state resets

### 6. Test

- [ ] Create a `ProviderContainer` with overrides for dependencies
- [ ] Verify state transitions: initial → loading → data/error
- [ ] Test notifier methods independently
- [ ] Run `make preflight`
