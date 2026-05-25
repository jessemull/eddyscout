---
name: navigation-change
description: >-
  Add, modify, or remove routes and navigation flows in EddyScout using
  go_router and typed routes. Use when changing routing structure, adding
  deep links, implementing auth guards, or modifying back-stack behavior.
---

# Navigation Change

Read the following before modifying any navigation logic:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/NAVIGATION.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/SECURITY.md`
- `docs/TESTING.md`
- `docs/UI.md`
- `docs/ACCESSIBILITY.md`

Companion skills:
- `code-generation` — route generation via `go_router_builder` and `make gen`
- `testing` — widget and integration test conventions for navigation flows
- `security-review` — auth guards, deep link validation, redirect safety
- `accessibility-review` — focus management and screen reader behavior on route changes

Navigation is a **core application architecture system**, not a UI detail.

It controls:
- routing structure
- feature boundaries
- authentication flows
- deep linking behavior
- back stack behavior
- user session state transitions

Incorrect navigation design leads to:
- broken UX flows
- security issues
- state corruption
- inconsistent back behavior
- hard-to-debug lifecycle issues

---

# When to Use

Use this skill when:

- adding new routes
- modifying existing routes
- removing routes
- changing navigation flows
- adding deep links
- implementing auth redirects
- implementing route guards
- restructuring navigation hierarchy
- introducing nested navigation shells
- modifying back-stack behavior

---

# Core Navigation Principles

## Navigation Is a State Machine

Navigation is not just routing — it is a state transition system:

```text
Route A → Route B → Route C
```

Each transition must be:
- deterministic
- testable
- predictable
- reversible where appropriate

---

## Typed Navigation Only

All routes must be:
- strongly typed
- compile-time safe
- generated via `go_router_builder` (run `make gen`)

No string-based navigation is allowed for application routes.

---

## Ownership Matters

Each feature owns its routes.

Avoid:
- centralized route dumping
- cross-feature route mutation
- implicit route coupling

---

# 1. Add a Typed Route

## Route Definition

- [ ] define route using `@TypedGoRoute`
- [ ] place route in feature module
- [ ] define required parameters explicitly
- [ ] define query parameters explicitly

## Parameter Rules

- [ ] required params must be non-nullable
- [ ] optional params must have safe defaults
- [ ] avoid dynamic parsing in UI layer
- [ ] validate inputs at route boundary

## Naming Rules

- [ ] route names must match feature intent
- [ ] avoid generic names (`page`, `screen1`)
- [ ] ensure consistency across feature routes

---

# 2. Code Generation

Run:

```bash id="gen_nav"
make gen
```

Verify:

- [ ] route classes generated correctly
- [ ] extension methods generated
- [ ] no build_runner errors
- [ ] analyzer clean

---

# 3. Router Registration

## GoRouter Setup

- [ ] register route in `GoRouter` config
- [ ] maintain correct nesting structure
- [ ] ensure route hierarchy reflects feature hierarchy

## Nesting Rules

- [ ] parent routes define shared layout shells
- [ ] child routes inherit navigation context
- [ ] avoid unnecessary deep nesting

## Route Uniqueness

- [ ] ensure path uniqueness
- [ ] avoid conflicting route patterns
- [ ] validate parameter collisions

---

# 4. Navigation Types

## GoRouter Usage Rules

### context.go()

Use when:
- replacing entire navigation stack
- top-level navigation changes
- switching tabs or root flows

### context.push()

Use when:
- drilling into detail pages
- pushing modal-style screens
- temporary navigation layers

### context.pop()

Use when:
- returning to previous screen
- closing modal routes
- reversing push navigation

---

# 5. Auth Guards & Route Protection

## Redirect Logic

- [ ] implement redirect in router config
- [ ] check auth state via Riverpod
- [ ] avoid side effects in redirect logic
- [ ] ensure redirect is deterministic

## Unauthorized Handling

- [ ] redirect unauthenticated users to login
- [ ] preserve intended destination if required
- [ ] handle expired sessions gracefully
- [ ] avoid redirect loops

## Security Rules

- [ ] sensitive routes protected
- [ ] deep links validated against auth state
- [ ] no client-side bypass of guards

---

# 6. Deep Linking

## Cold Start Behavior

- [ ] route resolves correctly on app launch
- [ ] parameters parsed correctly
- [ ] auth state applied before rendering protected routes

## Testing Deep Links

- [ ] test via `flutter run --route`
- [ ] test malformed URLs
- [ ] test missing parameters
- [ ] test extra parameters

## Robustness

- [ ] invalid routes handled gracefully
- [ ] fallback route defined
- [ ] error states do not crash app

---

# 7. Back Stack Behavior

## Stack Integrity

- [ ] back navigation behaves predictably
- [ ] no orphaned routes remain
- [ ] modal routes behave correctly

## Expected Behavior

- [ ] system back button works correctly
- [ ] `context.pop()` behaves consistently
- [ ] nested navigation preserved correctly

## Nested Navigation

- [ ] shell routes maintain independent stacks
- [ ] tab navigation preserves state
- [ ] switching tabs does not reset unnecessarily

---

# 8. Navigation State & Riverpod

## State Alignment

- [ ] navigation reflects app state correctly
- [ ] auth state syncs with routing state
- [ ] no mismatch between UI and route state

## Provider Safety

- [ ] navigation does not trigger unintended rebuild loops
- [ ] no side effects in build methods
- [ ] redirect logic does not depend on unstable state

---

# 9. Error Handling

## Route Failures

- [ ] missing parameters handled gracefully
- [ ] invalid deep links handled gracefully
- [ ] fallback route available

## UX Behavior

- [ ] user never sees blank screen on navigation failure
- [ ] error routes are user-friendly
- [ ] retry or recovery paths exist where needed

---

# 10. Performance Considerations

- [ ] avoid unnecessary route rebuilds
- [ ] minimize navigation-induced rebuild cascades
- [ ] lazy-load heavy screens where possible
- [ ] avoid expensive work during route transitions

---

# 11. Accessibility Requirements

- [ ] focus order resets correctly on route change
- [ ] screen reader announces route changes
- [ ] navigation context preserved for assistive tech
- [ ] no focus traps during transitions

---

# 12. Testing Requirements

## Unit Tests

- [ ] route configuration tested
- [ ] guard logic tested
- [ ] redirect logic tested

## Widget Tests

- [ ] navigation flow tested
- [ ] back stack behavior tested
- [ ] deep link behavior tested

## Integration Tests

- [ ] full navigation flows validated
- [ ] auth flows validated
- [ ] multi-step flows validated

---

# 13. Common Anti-Patterns

## MUST NOT

- [ ] use string-based routing for app navigation
- [ ] bypass typed route system
- [ ] implement navigation side effects in widgets
- [ ] create redirect loops
- [ ] ignore auth state in protected routes
- [ ] break back-stack consistency

## SHOULD AVOID

- [ ] overly deep route nesting
- [ ] global navigation mutation
- [ ] mixing navigation logic across layers
- [ ] implicit route dependencies

---

# 14. Validation Checklist

Before committing:

- [ ] routes generated successfully
- [ ] router config updated
- [ ] auth guards verified
- [ ] deep links tested
- [ ] back stack validated
- [ ] tests pass
- [ ] preflight passes

Run:

```bash
make preflight
```

---

# 15. Output Expectations

When performing navigation changes, provide:

## Change Summary
- routes added/modified/removed
- affected features

## Navigation Flow Description
- before vs after behavior
- stack changes
- auth implications

## Risk Assessment
- back-stack risk
- deep link risk
- auth/redirect risk

## Validation Results
- test coverage
- deep link tests
- build status
