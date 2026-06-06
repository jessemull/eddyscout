---
name: riverpod-usage
description: >-
  Create, consume, and refactor Riverpod providers in EddyScout. Use when
  adding providers, managing async state, handling lifecycle, or optimizing
  rebuild performance.
---

# Riverpod Usage

Read the following before creating, consuming, or refactoring any provider:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/ARCHITECTURE.md`
- `docs/TESTING.md`
- `docs/PERFORMANCE.md`

Companion skills:
- `state-management` — broader state design decisions and layer boundaries
- `testing` — provider testing with `ProviderContainer` and overrides
- `performance-profiling` — rebuild isolation and `ref.select()` optimization
- `debugging` — systematic investigation of provider-related bugs

Riverpod is the **single source of truth for application state**.

All state must be:
- explicit
- testable
- composable
- lifecycle-aware
- isolated by feature boundaries

---

# When to Use

Use this skill when:

- creating new providers
- refactoring state management
- introducing async data flows
- handling caching or derived state
- managing UI state (tabs, forms, filters)
- integrating APIs or repositories
- debugging state-related bugs

---

# Core Riverpod Principles

## State Must Be Predictable

All state transitions must be:
- deterministic
- observable
- testable
- free of hidden side effects

---

## Providers Are Not Business Logic Containers

Business logic belongs in:
- domain use cases
- repository layers
- services

Providers are for:
- orchestration
- composition
- lifecycle management

---

## Dependency Direction Is Strict

Dependency direction (per `AGENTS.md`):
```
presentation → domain ← data
```

Both presentation and data depend on domain. Domain depends on neither.

Call flow (how requests propagate at runtime):
```
UI → Provider → Domain → Data
```

Forbidden dependencies:
- data → presentation
- domain → presentation
- domain → data
- providers depending on presentation layer

---

# 1. Provider Type Selection

## Decision Matrix

| Need | Provider Type |
|------|--------------|
| Derived/computed value | `Provider` / `@riverpod` getter |
| Async fetch (read-only) | `FutureProvider` / `@riverpod` async getter |
| Stream of updates | `StreamProvider` |
| Mutable local state | `NotifierProvider` |
| Async mutable state | `AsyncNotifierProvider` |

---

## Rules

- [ ] **new** providers SHOULD use `@riverpod` codegen (existing manual `FutureProvider` / `NotifierProvider` / `AsyncNotifier` are acceptable until migrated)
- [ ] avoid new manual provider declarations unless codegen is blocked
- [ ] keep providers small and focused

---

# 2. Layer Placement Rules

## Strict Separation

- domain:
  - business logic orchestration
  - use cases
- data:
  - API calls, persistence, DTO mapping
- presentation:
  - UI state only (tabs, filters, ephemeral UI state)

## Rules

- [ ] no UI logic in domain or data providers
- [ ] no API calls in presentation providers
- [ ] providers must respect feature boundaries

---

# 3. Lifecycle Management

## autoDispose Policy

- [ ] default to `autoDispose` behavior
- [ ] do not retain state unnecessarily
- [ ] release memory when not in use

## KeepAlive Rules

Only use `keepAlive` when:
- global app state (auth session, config, theme)
- cross-screen shared caches
- long-lived subscriptions

---

# 4. AsyncValue Handling

## Required Handling

All async providers must handle:

- loading
- error
- data

## Rules

- [ ] never assume `.value` exists
- [ ] always handle `.when(...)`
- [ ] surface user-friendly errors
- [ ] avoid exposing raw exceptions to UI

---

## Error Handling Strategy

- transform domain errors into UI-safe messages
- log technical errors separately
- provide retry mechanisms where appropriate

---

# 5. Side Effects Rules

## Strict Separation

Side effects MUST NOT occur in:
- provider build methods
- widget build methods
- domain logic

## Allowed Patterns

- `ref.listen` for:
  - navigation
  - snackbars
  - analytics events

- `ref.invalidate` for:
  - cache refresh
  - re-fetch triggers

---

# 6. State Mutation Rules

## Allowed

- notifier methods for controlled updates
- explicit state transitions
- immutable state updates (preferred via `freezed`)

## Forbidden

- direct mutation of state objects
- hidden side effects inside getters
- asynchronous state mutation without proper async handling

---

# 7. Provider Design Patterns

## Preferred Patterns

- feature-scoped providers
- composable providers
- small single-responsibility providers
- derived state via composition instead of duplication

---

## Anti-Patterns

## MUST NOT

- global monolithic providers
- mixing UI + domain logic in same provider
- duplicating API calls across providers
- storing UI state in domain layer

## SHOULD AVOID

- deeply nested provider dependencies
- overusing `watch` at root widget level
- unnecessary recomputation in build

---

# 8. Performance Considerations

- [ ] use `ref.select` for granular rebuild control
- [ ] avoid broad `watch` subscriptions
- [ ] split providers to reduce rebuild scope
- [ ] cache expensive computations
- [ ] avoid recomputation in `build`

---

# 9. Testing Strategy

## Provider Testing

- [ ] use `ProviderContainer`
- [ ] override dependencies explicitly
- [ ] test state transitions:
  - initial → loading → success
  - initial → loading → error

## Notifier Testing

- [ ] test each public method independently
- [ ] verify state immutability
- [ ] ensure deterministic outcomes

## Integration Testing

- [ ] verify provider composition across features
- [ ] validate async flows

---

# 10. Debugging Providers

- [ ] use Riverpod DevTools
- [ ] inspect provider dependencies graph
- [ ] trace rebuild triggers
- [ ] verify disposal behavior
- [ ] check for unintended re-initialization

---

# 11. Security Considerations

- [ ] do not expose sensitive state in providers
- [ ] avoid caching secrets in memory longer than needed
- [ ] sanitize API responses before exposing to UI
- [ ] ensure auth state is properly isolated

---

# 12. Common Anti-Patterns

## MUST NOT

- [ ] perform API calls in widgets instead of providers
- [ ] mutate state directly
- [ ] ignore async error states
- [ ] leak domain logic into UI providers
- [ ] overuse global providers

## SHOULD AVOID

- [ ] unnecessary provider chaining
- [ ] redundant derived providers
- [ ] excessive recomputation

---

# 13. Validation Checklist

Before committing:

- [ ] correct provider type selected
- [ ] proper layer placement
- [ ] async states handled
- [ ] side effects isolated
- [ ] lifecycle correct (`autoDispose` where appropriate)
- [ ] tests pass
- [ ] push validation passes (`git push` hook; see `CONTEXT.md`)

Run while iterating:

```bash id="riverpod1"
make analyze
melos exec --scope=<package> -- "flutter test"
```

---

# 14. Output Expectations

When completing Riverpod work, provide:

## State Design Summary
- providers added/changed
- state responsibilities

## Dependency Graph Notes
- provider relationships
- layer boundaries respected

## Risk Assessment
- rebuild risks
- lifecycle risks
- async risks

## Testing Summary
- state transitions verified
- overrides used