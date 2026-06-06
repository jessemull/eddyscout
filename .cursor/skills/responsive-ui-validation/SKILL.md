---
name: responsive-ui-validation
description: >-
  Validate responsive layouts across breakpoints, orientations, and text
  scales. Use when building new screens, fixing overflow issues, or
  supporting tablets and desktop web.
---

# Responsive UI Validation

Read the following before building or validating any responsive UI:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/RESPONSIVENESS.md`
- `docs/ARCHITECTURE.md`
- `docs/UI.md`
- `docs/ACCESSIBILITY.md`
- `docs/TESTING.md`
- `docs/PERFORMANCE.md`

Companion skills:
- `accessibility-review` — text scaling, touch targets, and focus order
- `golden-testing` — visual regression tests at multiple breakpoints
- `testing` — widget test conventions for layout validation
- `performance-profiling` — rebuild cost of responsive layout logic

Responsive UI is a **core product requirement**, not a cosmetic enhancement.

Every layout must assume:
- different screen sizes
- different aspect ratios
- different text scales
- different input methods
- different device capabilities

---

# When to Use

Use this skill when:

- building new screens
- modifying existing layouts
- designing reusable components
- implementing adaptive layouts
- supporting tablets or desktop web
- fixing overflow issues
- improving UX across devices

---

# Core Responsive Principles

## Design Must Be Fluid, Not Fixed

Avoid:
- fixed widths
- hardcoded heights
- pixel-perfect assumptions
- single-device layouts

Prefer:
- flexible constraints
- adaptive layouts
- intrinsic sizing
- constraint-driven design

---

## Layout Must Adapt to Constraints

Every widget tree must respond to:
- available width
- available height
- orientation
- text scale
- platform differences

---

## Content Drives Layout

Layout should adapt to content, not the other way around.

---

# 1. Breakpoint System

## Standard Breakpoints

| Category | Width | Examples |
|----------|-------|---------|
| Phone (portrait) | < 600dp | Most phones |
| Phone (landscape) | < 600dp height | Rotated phones |
| Tablet (portrait) | 600–839dp | Small tablets |
| Tablet (landscape) | 840–1199dp | Large tablets |
| Desktop | ≥ 1200dp | Web / large screens |

---

# 2. Multi-Breakpoint Testing

## Required Viewports

- [ ] 360×640 (small phone)
- [ ] 390×844 (modern phone)
- [ ] 414×896 (large phone)
- [ ] phone landscape
- [ ] 768×1024 (tablet portrait)
- [ ] 1024×768 (tablet landscape)
- [ ] 1440×900 (desktop)

## Validation Rules

- [ ] no overflow errors
- [ ] no clipped content
- [ ] no unusable UI elements
- [ ] no hidden critical actions

---

# 3. Layout Construction Rules

## Required Widgets

- [ ] `LayoutBuilder` for adaptive layouts
- [ ] `MediaQuery` for screen metrics
- [ ] `Flexible` / `Expanded` instead of fixed sizing
- [ ] `Wrap` instead of `Row` when overflow is possible
- [ ] `FractionallySizedBox` for proportional layouts

---

## Avoid

- fixed pixel widths
- hardcoded spacing for all screens
- assuming minimum screen size
- non-scrollable overflow-prone layouts

---

# 4. Orientation Handling

## Requirements

- [ ] layout adapts on rotation
- [ ] state is preserved
- [ ] no overflow in landscape
- [ ] navigation remains usable
- [ ] scroll behavior remains consistent

---

## Rules

- orientation changes must NOT reset app state
- layout must reflow gracefully
- avoid separate UI trees per orientation unless necessary

---

# 5. Text Scaling Support

## Required Testing

- [ ] 1.0× scale (default)
- [ ] 1.5× scale
- [ ] 2.0× scale

## Rules

- [ ] no text clipping
- [ ] no overlap between UI elements
- [ ] no fixed-height text containers
- [ ] use theme typography only

---

# 6. Touch Target Requirements

## Minimum Standards

- [ ] ≥ 48×48 dp for all interactive elements
- [ ] sufficient spacing between tappable areas
- [ ] no dense clusters of buttons

## Mobile Usability

- [ ] one-handed reachability considered
- [ ] bottom navigation reachable
- [ ] floating actions accessible
- [ ] gestures do not conflict with scrolling

---

# 7. Adaptive Component Design

## Component Rules

- [ ] components must not assume screen size
- [ ] components must accept constraints from parent
- [ ] components must degrade gracefully
- [ ] components must be reusable across breakpoints

---

## Pattern Preference

- responsive widgets over duplicate layouts
- conditional layout branches only when necessary
- shared logic across breakpoints

---

# 8. Scroll & Overflow Handling

## Requirements

- [ ] scrollable content for small screens
- [ ] no hidden overflow
- [ ] no clipped interactive elements
- [ ] safe-area handling on all devices

## Rules

- avoid unbounded `Column` in scroll contexts
- ensure scroll views wrap content correctly
- handle keyboard appearance gracefully

---

# 9. Platform Responsiveness Interaction

- [ ] mobile vs desktop layout differences handled
- [ ] web uses wider layout strategies
- [ ] tablet uses hybrid layouts (not mobile scaled up)
- [ ] platform UI differences do not break responsiveness

---

# 10. Testing Strategy

## Widget Tests

- [ ] test multiple screen sizes via `tester.binding.window`
- [ ] verify layout adaptation logic
- [ ] verify no overflow exceptions

## Golden Tests (optional but recommended)

- [ ] key breakpoints covered
- [ ] phone + tablet layouts validated visually

---

# 11. Performance Considerations

- [ ] avoid rebuilding entire layout on resize
- [ ] avoid expensive layout calculations in build
- [ ] avoid repeated MediaQuery calls in deep trees
- [ ] ensure responsive logic is lightweight

---

# 12. Accessibility Alignment

Responsive UI must also ensure:
- readable text at all scales
- reachable controls
- consistent focus order
- no hidden interactive elements

---

# 13. Common Anti-Patterns

## MUST NOT

- [ ] fixed-width layouts for all screens
- [ ] separate screens per device type without abstraction
- [ ] ignore landscape layouts
- [ ] ignore tablet layouts
- [ ] assume single breakpoint design
- [ ] hide functionality on smaller screens

## SHOULD AVOID

- [ ] duplicated layout code per breakpoint
- [ ] excessive conditional UI branching
- [ ] relying on device-specific hacks

---

# 14. Validation Checklist

Before committing:

- [ ] tested all required breakpoints
- [ ] no overflow or clipping issues
- [ ] orientation changes verified
- [ ] text scaling verified
- [ ] touch targets validated
- [ ] tests pass
- [ ] push validation passes (`git push` hook; see `CONTEXT.md`)

Run while iterating:

```bash id="responsive1"
make analyze
melos exec --scope=<package> -- "flutter test"
```

---

# 15. Output Expectations

When completing responsive UI work, provide:

## Layout Summary
- breakpoints considered
- layout strategy used

## Adaptation Strategy
- how UI changes per screen size
- key responsive decisions

## Risk Assessment
- small screen risks
- tablet layout risks
- overflow risks

## Validation Results
- breakpoints tested
- overflow checks
- accessibility alignment
