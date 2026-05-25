---
name: state-management
description: >-
  Design and implement application state in EddyScout using Riverpod.
  Use when introducing new state, refactoring providers, deciding between
  UI vs domain state, or debugging state inconsistencies.
---

# State Management

Read the following before designing, implementing, or refactoring any state:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/ARCHITECTURE.md`
- `docs/TESTING.md`
- `docs/PERFORMANCE.md`

Companion skills:
- `riverpod-usage` — provider patterns, lifecycle, and `ref.select()` usage
- `testing` — provider testing with `ProviderContainer` and overrides
- `performance-profiling` — rebuild isolation and frame budget analysis
- `debugging` — systematic investigation of state-related bugs

State management is the **core architecture backbone** of the application.

All state must be:
- explicit
- testable
- minimal
- correctly scoped
- lifecycle-aware
- strictly layered

---

# When to Use

Use this skill when:

- introducing new application state
- refactoring existing providers
- deciding between UI vs domain state
- integrating APIs or repositories
- managing forms or user input
- handling async flows
- deriving computed values
- debugging state inconsistencies

---

# Core State Principles

## State Must Have a Clear Ownership Model

Every piece of state must answer:
- who owns it?
- who updates it?
- who consumes it?
- how long does it live?

---

## State Should Be Minimal and Derived Where Possible

Prefer:
- derived state over duplicated state
- composition over duplication
- computation over storage

Avoid:
- redundant state copies
- storing derived values unnecessarily

---

## State Must Respect Layer Boundaries

```
presentation → domain ← data
```

Never:
- let UI own business state
- let data layer depend on UI state
- bypass domain logic via providers

---

# 1. State Classification

## Types of State

| Type | Example | Recommended Provider |
|------|--------|----------------------|
| Remote/server state | API responses, user profile | `AsyncNotifierProvider` |
| Local UI state | tab index, modal open state | `StateProvider` / `NotifierProvider` |
| Derived state | filtered lists, computed values | `Provider` |
| Stream state | WebSockets, realtime feeds | `StreamProvider` |
| Form state | validation + inputs | `NotifierProvider` |

---

# 2. Provider Selection Rules

## Sync State

- simple value → `Provider`
- mutable state → `NotifierProvider`

## Async State

- one-time fetch → `FutureProvider`
- mutable async → `AsyncNotifierProvider`

## Streaming State

- event streams → `StreamProvider`

---

## Rules

- [ ] prefer `@riverpod` code generation for all providers
- [ ] avoid manual provider declarations unless required
- [ ] keep providers small and composable
- [ ] avoid monolithic “god providers”

---

# 3. Layer Placement Rules

## Strict Separation

- domain:
  - business logic
  - use cases
- data:
  - API, persistence, DTOs
- presentation:
  - UI state only (tabs, toggles, animation state)

---

## Rules

- [ ] no API calls in presentation providers
- [ ] no UI logic in domain/data providers
- [ ] providers must respect feature boundaries
- [ ] no cross-feature state leakage

---

# 4. Lifecycle Management

## autoDispose Policy

- [ ] default to `autoDispose`
- [ ] release unused state automatically
- [ ] prevent memory leaks by design

## keepAlive Policy

Only for:
- auth session
- app config
- global caches
- theme/state shared across app lifecycle

---

## Conditional KeepAlive

- [ ] use `ref.keepAlive()` only when necessary
- [ ] document reason for persistence

---

# 5. Async State Handling

## Required Handling

All async state must handle:

- loading
- error
- data

## Rules

- [ ] never assume data exists
- [ ] always use `.when(...)` in UI
- [ ] provide retry mechanisms for failures
- [ ] convert technical errors into user-safe messages

---

# 6. Side Effects Rules

## Strict Isolation

Side effects MUST NOT occur in:
- provider constructors
- widget build methods
- domain logic

## Allowed Mechanism

- `ref.listen` for:
  - navigation
  - snackbars
  - analytics events

- `ref.invalidate` for:
  - refresh triggers
  - cache resets

---

# 7. State Mutation Rules

## Allowed

- explicit notifier methods
- immutable state updates
- controlled async transitions

## Forbidden

- direct mutation of state objects
- hidden mutations in getters
- implicit side effects during reads

---

# 8. Performance Considerations

- [ ] use `ref.select` for fine-grained rebuilds
- [ ] split large providers into smaller ones
- [ ] avoid over-watching global state
- [ ] cache expensive derived computations
- [ ] avoid recomputation in build

---

# 9. Testing Strategy

## Provider Testing

- [ ] use `ProviderContainer`
- [ ] override dependencies explicitly
- [ ] test state transitions:
  - initial → loading → success
  - initial → loading → error

## Notifier Testing

- [ ] test each method independently
- [ ] ensure deterministic outcomes
- [ ] validate immutability of state

## Integration Testing

- [ ] verify provider composition across features
- [ ] validate cross-provider interactions

---

# 10. Debugging State

- [ ] use Riverpod DevTools
- [ ] inspect dependency graph
- [ ] trace rebuild triggers
- [ ] validate disposal behavior
- [ ] detect unintended reinitialization

---

# 11. Security Considerations

- [ ] do not store secrets in providers
- [ ] isolate auth state from UI state
- [ ] clear sensitive state on logout
- [ ] avoid persistent sensitive caching
- [ ] sanitize data before exposure to UI

---

# 12. Common Anti-Patterns

## MUST NOT

- [ ] store API calls in widgets
- [ ] mix UI + domain state in same provider
- [ ] mutate state directly
- [ ] ignore async error handling
- [ ] create global monolithic providers
- [ ] bypass domain layer via providers

## SHOULD AVOID

- [ ] redundant derived providers
- [ ] excessive provider chaining
- [ ] overuse of global state
- [ ] unnecessary recomputation

---

# 13. Validation Checklist

Before committing:

- [ ] correct provider type selected
- [ ] proper layer placement enforced
- [ ] async states handled correctly
- [ ] side effects isolated
- [ ] lifecycle rules respected
- [ ] tests pass
- [ ] preflight passes

Run:

```bash
make preflight
```

---

# 14. Output Expectations

When completing state management work, provide:

## State Design Summary
- what state exists
- ownership model

## Provider Graph
- dependencies between providers
- layer boundaries respected

## Risk Assessment
- lifecycle risks
- rebuild risks
- async risks

## Testing Summary
- transitions tested
- overrides used