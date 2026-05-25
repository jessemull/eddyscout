---
name: feature-development
description: >-
  Implement new features for EddyScout following architecture rules, state
  management conventions, and quality gates. Use when creating features,
  adding screens, domain logic, providers, routes, or API integrations.
---

# Feature Development

Read the following before implementing any feature:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/TESTING.md`
- `docs/PERFORMANCE.md`
- `docs/SECURITY.md`
- `docs/UI.md`
- `docs/NAVIGATION.md`
- `docs/DEPENDENCIES.md`
- `docs/CODEGEN.md`
- `docs/ACCESSIBILITY.md`
- `docs/NETWORKING.md`
- `docs/REVIEW.md`

Conditional reads:
- `docs/ERROR_HANDLING.md` — when feature involves error/retry/offline flows
- `docs/LOCALIZATION.md` — when feature adds user-facing strings
- `docs/PLATFORMS.md` — when feature includes platform-specific code

Companion skills (use for deeper passes in specific areas):
- `pr-review` — pre-merge review
- `accessibility-review` — deep a11y audit
- `riverpod-usage` — provider patterns
- `navigation-change` — route changes
- `code-generation` — freezed, json_serializable, riverpod_generator
- `commit` — commit preparation
- `testing` — test conventions
- `security-review` — security audit
- `performance-profiling` — performance analysis

Feature development must preserve:
- architecture integrity
- repository consistency
- performance characteristics
- accessibility compliance
- testing quality
- maintainability
- deterministic behavior

Features must be:
- scalable
- testable
- composable
- observable
- reviewable
- and safe for long-term maintenance

---

# When to Use

Use this skill when:

- creating a new feature
- implementing feature flows
- adding new screens
- adding domain functionality
- adding repositories/data sources
- adding Riverpod providers
- adding routes/navigation
- adding API integrations
- adding persistence/storage
- implementing forms
- implementing async workflows

This skill covers:
- architecture
- scaffolding
- domain design
- state management
- presentation
- testing
- performance
- accessibility
- CI validation
- PR preparation

---

# Core Feature Development Principles

## Domain-Driven Architecture

Features must follow:

```text
presentation → domain ← data
```

Rules:
- `presentation` depends on `domain`
- `data` depends on `domain`
- `domain` depends on neither `presentation` nor `data`
- `presentation` must never directly depend on data sources

**App shell:** Screen widgets may live in `apps/eddyscout/lib/screens/` while feature packages mature. New UI SHOULD move toward feature `presentation/` when the feature owns the screen. See `docs/ARCHITECTURE.md` § Current implementation status.

**Routing:** Register typed routes in `apps/eddyscout/lib/routing/` today (`navigation-change` skill). Target: compose in `packages/routing/`.

---

## Feature Ownership

Features own:
- routes
- providers
- domain logic
- repositories
- widgets
- feature-specific models

Avoid:
- hidden cross-feature coupling
- shared mutable state
- feature leakage
- duplicated ownership

---

## Minimize Complexity

Prefer:
- small composable widgets
- focused providers
- explicit async states
- deterministic state flows
- repository abstractions

Avoid:
- god widgets
- global mutable state
- hidden side effects
- deeply nested rebuild trees
- over-abstraction

---

# 1. Initial Feature Planning

Before implementation:

- [ ] Understand product requirements
- [ ] Identify architecture impact
- [ ] Identify navigation impact
- [ ] Identify state management requirements
- [ ] Identify persistence requirements
- [ ] Identify async flows
- [ ] Identify accessibility requirements
- [ ] Identify performance-sensitive areas
- [ ] Identify analytics requirements
- [ ] Identify security implications

---

# 2. Repository Context Review

Read and understand:

- [ ] `CONTEXT.md`
- [ ] `AGENTS.md`
- [ ] architecture boundaries
- [ ] state management rules
- [ ] navigation conventions
- [ ] testing conventions
- [ ] design system rules
- [ ] accessibility requirements
- [ ] dependency rules
- [ ] code generation workflows

Do not implement features before understanding repository conventions.

---

# 3. Feature Scaffolding

## Package Creation

If using feature packages:

- [ ] Copy `packages/features/_TEMPLATE/`
- [ ] Rename package references
- [ ] Update `pubspec.yaml`
- [ ] Register workspace package if required

## Directory Structure

Required structure:

```text
feature/
├── domain/
├── data/
├── presentation/
├── application/        # optional orchestration layer
├── widgets/            # optional reusable feature widgets
├── providers/          # optional provider grouping
├── routes/             # optional route grouping
└── tests/
```

Structure should remain:
- predictable
- scalable
- discoverable

---

# 4. Domain Layer Development

The domain layer is the source of truth.

Implement domain first.

## Entities

- [ ] Entities immutable
- [ ] Use `freezed`
- [ ] Nullability intentional
- [ ] State modeling explicit
- [ ] Invalid states impossible where practical

## Repository Contracts

- [ ] Repositories defined as abstractions
- [ ] Interfaces stable and minimal
- [ ] No infrastructure concerns leaked
- [ ] No UI concerns leaked

## Use Cases

- [ ] Use cases focused
- [ ] Use cases composable
- [ ] Business rules isolated
- [ ] Async behavior explicit

## Domain Rules

- [ ] No Flutter imports
- [ ] No networking code
- [ ] No persistence code
- [ ] No UI dependencies

---

# 5. Data Layer Development

The data layer implements domain contracts.

## Repository Implementations

- [ ] Repository contracts implemented correctly
- [ ] Data mapping isolated
- [ ] Errors normalized
- [ ] Async failures handled consistently

## DTOs & Serialization

- [ ] DTOs separated from entities
- [ ] Serialization generated correctly
- [ ] API compatibility preserved
- [ ] Nullability intentional

## Data Sources

- [ ] Remote/local responsibilities separated
- [ ] Caching strategy explicit
- [ ] Retry behavior intentional
- [ ] Offline handling considered

## Data Rules

- [ ] No UI logic
- [ ] No widget imports
- [ ] No presentation coupling

---

# 6. State Management Development

## Riverpod Architecture

- [ ] Correct provider types selected
- [ ] Providers focused and composable
- [ ] Provider ownership clear
- [ ] Provider scope minimized

## Async State Handling

- [ ] Loading states handled
- [ ] Error states handled
- [ ] Empty states handled
- [ ] Success states handled
- [ ] Retry behavior considered

## Lifecycle Safety

- [ ] `autoDispose` considered intentionally
- [ ] Provider invalidation scoped correctly
- [ ] No retained provider leaks
- [ ] Async lifecycle safe

## Rebuild Safety

- [ ] `ref.watch` scope minimized
- [ ] Expensive rebuilds isolated
- [ ] Selectors used where appropriate

---

# 7. Presentation Layer Development

## Widget Design

- [ ] Widgets single-purpose
- [ ] Widget composition preferred
- [ ] Large widgets extracted
- [ ] Build methods lightweight

## Build Safety

- [ ] No async work in `build()`
- [ ] No side effects in `build()`
- [ ] No expensive sync computation in `build()`
- [ ] No unnecessary object allocation in `build()`

## Immutability

- [ ] `const` constructors used
- [ ] Mutable shared state avoided
- [ ] Widget inputs explicit

## Error Handling

- [ ] Graceful loading states
- [ ] Graceful empty states
- [ ] Graceful failure states
- [ ] Retry UX exists where appropriate

---

# 8. Navigation Development

## Routing

- [ ] Typed routes used
- [ ] Route ownership respected
- [ ] Deep links validated
- [ ] Navigation side effects isolated

## Navigation Safety

- [ ] Required params validated
- [ ] Invalid navigation states avoided
- [ ] Auth guards implemented correctly
- [ ] Back stack behavior intentional

---

# 9. Design System Compliance

## UI Consistency

- [ ] Material 3 tokens used
- [ ] Typography tokens used
- [ ] Semantic colors used
- [ ] Hardcoded styling avoided

## Responsiveness

- [ ] Phone layouts supported
- [ ] Tablet layouts supported
- [ ] Landscape layouts supported
- [ ] Overflow handling verified

## Dark Mode

- [ ] Dark theme verified
- [ ] Contrast validated
- [ ] No hardcoded light-only colors

---

# 10. Accessibility Development

## Semantics

- [ ] Interactive elements labeled
- [ ] Semantic hierarchy correct
- [ ] Decorative elements excluded appropriately

## Interaction Accessibility

- [ ] Touch targets ≥ 48x48dp
- [ ] Keyboard navigation supported where applicable
- [ ] Focus order logical

## Visual Accessibility

- [ ] Text scaling supported
- [ ] WCAG contrast requirements met
- [ ] Color not sole information channel

---

# 11. Performance Development

## Rebuild Isolation

- [ ] Rebuild scope minimized
- [ ] Large lists optimized
- [ ] Expensive widgets isolated
- [ ] Animation rebuilds isolated

## Rendering Performance

- [ ] Lazy loading used appropriately
- [ ] Images optimized
- [ ] Heavy sync work avoided
- [ ] Excessive widget nesting avoided

## Memory Safety

- [ ] Controllers disposed
- [ ] Streams disposed
- [ ] Timers cleaned up
- [ ] Subscriptions cancelled

---

# 12. Security Development

## Sensitive Data

- [ ] No secrets hardcoded
- [ ] PII not logged
- [ ] Sensitive state protected

## Network Security

- [ ] HTTPS enforced
- [ ] Auth state handled safely
- [ ] Unsafe WebView behavior avoided

## Input Validation

- [ ] User input validated
- [ ] Unsafe assumptions avoided
- [ ] Defensive parsing implemented where necessary

---

# 13. Analytics & Observability

## Analytics

- [ ] Analytics events implemented correctly
- [ ] Naming conventions followed
- [ ] Duplicate events avoided
- [ ] PII not tracked

## Logging

- [ ] Logs structured appropriately
- [ ] Debug noise minimized
- [ ] Sensitive data redacted

---

# 14. Code Generation

Run:

```bash
make gen
```

Verify:

- [ ] generated providers updated
- [ ] generated routes updated
- [ ] serialization updated
- [ ] no stale generated artifacts

Then run:

```bash
make gen-check
```

---

# 15. Testing Development

## Unit Tests

- [ ] Domain logic tested
- [ ] Repository logic tested
- [ ] Edge cases tested
- [ ] Failure states tested

## Widget Tests

- [ ] Screens tested
- [ ] State transitions tested
- [ ] Async flows tested
- [ ] Accessibility assertions included where appropriate

## Integration Tests (required for critical user journeys)

- [ ] Critical flows covered
- [ ] Navigation flows covered
- [ ] Auth flows covered where applicable

## Test Quality

- [ ] Tests deterministic
- [ ] No real network, file system, or platform channels
- [ ] No flaky timing assumptions
- [ ] Mock external I/O (network, storage, platform) with `mocktail`; avoid mocking domain logic under test

---

# 16. Regression Prevention

- [ ] Existing behavior preserved
- [ ] Existing tests still pass
- [ ] Related flows manually verified
- [ ] Architecture drift avoided

---

# 17. Validation & Quality Gates

Run:

```bash
make preflight
```

Verify:

- [ ] analyzer passes
- [ ] formatting passes
- [ ] tests pass
- [ ] codegen clean
- [ ] dependency validation passes
- [ ] CI-compatible

---

# 18. PR Preparation

## Commit

Use Conventional Commits:

```text
feat(<scope>): <description>
```

## PR Review

Before PR:
- [ ] run `pr-review` skill
- [ ] run `accessibility-review` skill for UI changes
- [ ] review architecture impact
- [ ] review performance impact
- [ ] review security impact

---

# 19. AI-Assisted Development Validation

## AI Safety

- [ ] No hallucinated APIs/packages
- [ ] Existing repository patterns reused
- [ ] Architecture preserved
- [ ] Existing abstractions preferred

## Complexity Review

- [ ] No overengineering
- [ ] No unnecessary abstractions
- [ ] Boilerplate justified
- [ ] Feature complexity proportional to requirements

---

# 20. Common Feature Development Anti-Patterns

## MUST NOT

- [ ] Put business logic in widgets
- [ ] Bypass architecture boundaries
- [ ] Introduce global mutable state
- [ ] Ignore async lifecycle safety
- [ ] Ignore loading/error states
- [ ] Ignore accessibility
- [ ] Ignore performance implications
- [ ] Ignore tests

## SHOULD AVOID

- [ ] Giant widgets
- [ ] Excessive provider nesting
- [ ] Deeply coupled features
- [ ] Premature abstraction
- [ ] Excessive code generation
- [ ] Massive monolithic providers

---

# 21. Final Feature Checklist

Before merge:

- [ ] architecture compliant
- [ ] state management compliant
- [ ] navigation compliant
- [ ] accessibility compliant
- [ ] performance reviewed
- [ ] security reviewed
- [ ] tests pass
- [ ] analyzer passes
- [ ] codegen passes
- [ ] documentation updated
- [ ] CI passes

---

# Output Expectations

When implementing a feature, provide:

## Feature Summary
- feature purpose
- affected packages/features
- architectural impact

## State Management Summary
- providers added
- async flows introduced
- lifecycle considerations

## Validation Results
- tests added
- analyzer status
- performance considerations
- accessibility considerations

## Risks & Follow-Ups
- known limitations
- future improvements
- rollout considerations