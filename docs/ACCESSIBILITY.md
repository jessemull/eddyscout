# Accessibility

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read this file when implementing or reviewing user-facing UI; when adding interactive widgets, forms, navigation flows, or animations; when auditing accessibility compliance; or when reviewing PRs with UI changes.

---

## Non-Negotiable Minimums

These requirements apply to every widget that displays content or accepts interaction. Violations are PR blockers (MUST severity per `REVIEW.md`).

| Requirement | Standard | Details |
|-------------|----------|---------|
| Semantic labels | All interactive elements | `semanticLabel`, `Semantics` wrapper, or `tooltip`. See `UI.md` §Accessibility. |
| Touch targets | ≥ 48×48 logical pixels | Material 3 guideline. See `RESPONSIVENESS.md` §Touch Targets. |
| Color contrast | WCAG 2.1 AA | Normal text ≥ 4.5:1, large text ≥ 3:1, icons/controls ≥ 3:1. |
| Screen reader order | Logical reading order = visual order | Test with TalkBack (Android) and VoiceOver (iOS). |
| Text scaling | Layouts accommodate 0.8×–2.0× | No overflow, no clipping. Never cap `textScaleFactor`. See `RESPONSIVENESS.md` §Text Scaling. |
| No color-only information | Color supplemented with text/icons/patterns | Status indicators, errors, selections must be distinguishable without color. |
| Dark mode | All screens correct in both themes | No hardcoded light-only colors. Use `colorScheme` tokens. See `THEMING.md`. |
| Decorative exclusion | Decorative images/icons excluded | `excludeFromSemantics: true` on decorative `Image` widgets. |
| Dynamic announcements | State changes announced | Use `SemanticsService.announce()` for dynamic content updates without focus change. |

---

## Platform Verification Matrix

Accessibility must be verified on all supported platforms:

| Platform | Verification |
|----------|-------------|
| Android | TalkBack navigation, touch targets, contrast |
| iOS | VoiceOver navigation, touch targets, contrast |
| Tablet | Layout adaptation, touch targets at larger sizes |
| Landscape | No content loss, logical reflow |
| Web/desktop | Keyboard navigation, focus indicators, hover not required |
| Dark mode | Contrast valid, images/icons visible, semantic colors used |
| Large text (2.0×) | No overflow, no clipping, scrollable fallback where needed |

---

## Semantic Widgets

From `AGENTS.md`:

- Use `Semantics` for all custom-drawn or non-standard components.
- Provide meaningful `label`, `hint`, and `value` properties.
- Group related elements with `MergeSemantics` where appropriate.
- Mark decorative images with `excludeFromSemantics: true`.
- Announce dynamic content changes with `SemanticsService.announce()`.

---

## Keyboard & Focus

- Implement proper focus traversal order using `FocusTraversalGroup` and `FocusTraversalOrder`.
- Show visible focus indicators on all interactive elements.
- Support keyboard navigation for web platform.
- Modal dialogs must trap focus while open and restore focus on close.
- No unintended focus traps — users must always be able to navigate away.

---

## Forms

- All inputs must have visible or semantic labels (not placeholder-only).
- Required fields must be identified both visually and semantically.
- Validation errors must be announced accessibly and displayed with user-friendly text.
- Correct `TextInputType` and autofill hints should be provided.

---

## Animation & Motion

- Excessive motion must be avoided.
- Motion must not be required for understanding content.
- Respect reduced-motion preferences where feasible (`MediaQuery.disableAnimations`).
- No flashing content (seizure risk).

---

## Severity in PR Review

Per `REVIEW.md`:

- **MUST (blocking):** Issues that block assistive technology, break keyboard navigation, create unreadable content, prevent interaction, fail contrast, or trap focus.
- **SHOULD:** Reduced usability, inconsistent behavior, degraded screen reader experience.
- **NICE TO HAVE:** Additional semantic clarity, refined traversal, enhanced motion reduction.

---

## Related Documents

| Document | Scope |
|----------|-------|
| `UI.md` §Accessibility | Per-widget accessibility minimums |
| `RESPONSIVENESS.md` | Touch targets, text scaling, adaptive layout |
| `THEMING.md` | Dark mode, semantic color tokens |
| `REVIEW.md` | Accessibility review checklist for PRs |
| `AGENTS.md` §Accessibility | Non-negotiable semantic and focus rules |

For deep accessibility audits, use the `accessibility-review` skill (`.cursor/skills/accessibility-review/SKILL.md`).
