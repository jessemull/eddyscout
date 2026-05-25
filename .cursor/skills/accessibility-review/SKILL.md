---
name: accessibility-review
description: >-
  Audit and review accessibility (a11y) for EddyScout UI: semantics, screen
  readers, keyboard/focus, contrast, text scaling, forms, and motion. Use when
  implementing or reviewing user-facing widgets, forms, navigation, theming,
  or PRs with UI changes.
---

# Accessibility Review

> Read `CONTEXT.md` and `AGENTS.md` before performing any accessibility review.
>
> Accessibility is a non-negotiable quality requirement.
>
> Accessibility issues that block interaction, navigation, readability, or assistive technology usage are **MUST** (blocking) issues.
>
> Accessibility must be verified across:
>
> - Android
> - iOS
> - Tablet layouts
> - Landscape layouts
> - Desktop/web keyboard navigation (when the surface is supported on web)
> - Dark mode
> - Large text scaling (up to 2.0× per `docs/UI.md`; also test extreme system sizes when feasible)

Canonical UI accessibility minimums: `docs/UI.md`, `docs/RESPONSIVENESS.md`, `docs/THEMING.md`. PR-wide review: use `pr-review` skill (§9); this skill is the deep a11y pass.

---

## When to use

Use when:

- Auditing accessibility (a11y)
- Implementing new UI
- Reviewing pull requests (UI or design-system changes)
- Creating reusable widgets
- Building forms (also see `form-creation` skill for validation/state patterns)
- Implementing navigation
- Adding animations
- Modifying typography or theming
- Implementing dialogs, overlays, or bottom sheets

Accessibility review is **required** for:

- All user-facing UI
- Reusable components
- Navigation flows
- Forms
- Authentication flows
- Onboarding flows
- Settings screens
- Modal interactions

---

## References

| Document | Use for |
|----------|---------|
| `CONTEXT.md`, `AGENTS.md` | Non-negotiable constraints |
| `docs/ACCESSIBILITY.md` | Governance index for a11y requirements |
| `docs/UI.md` | Per-widget minimums, loading/error/empty states |
| `docs/THEMING.md` | Theme tokens, dark mode |
| `docs/RESPONSIVENESS.md` | Breakpoints, text scale, touch targets |
| `docs/ARCHITECTURE.md` | Widget layering; no business logic in widgets |
| `docs/REVIEW.md` | Severity tiers and PR accessibility checklist |
| `docs/NAVIGATION.md` | Route transitions, focus after navigation |
| Material 3 accessibility guidelines | Platform patterns |
| WCAG 2.1 Level AA | Contrast, non-color cues, keyboard |

---

## Review workflow

Execute in order:

1. **Scope** — List screens/widgets in the diff or audit target; note platforms (Android, iOS, web).
2. **Load context** — Skim `docs/UI.md` and `docs/RESPONSIVENESS.md` sections that apply.
3. **Static review** — Walk §1–§13 against source (semantics, contrast tokens, layout).
4. **Assistive-tech pass** — Where possible, note TalkBack/VoiceOver/keyboard checks needed on device or emulator (call out if only static review was possible).
5. **Output** — Use **Review output format** below; map blockers to **MUST**.

Mark checklist items **N/A** only when the change clearly does not touch that area.

---

## Accessibility severity levels

### MUST

Issues that:

- Block assistive technology usage
- Break keyboard navigation
- Create unreadable content
- Prevent interaction
- Fail critical contrast requirements (WCAG AA for required text/controls)
- Create inaccessible forms
- Trap focus incorrectly (unintended traps) or fail to trap/restore focus in modals
- Hide important semantics from assistive tech

Must be fixed before merge.

### SHOULD

Issues that:

- Reduce usability
- Create inconsistent accessibility behavior
- Degrade screen reader experience
- Reduce clarity or discoverability
- Create moderate accessibility friction

Should generally be fixed before merge unless intentionally deferred (document deferral and link a follow-up issue).

### NICE TO HAVE

Minor improvements such as:

- Additional semantic clarity
- Improved announcements (`SemanticsService.announce` for dynamic updates)
- Refined traversal ordering
- Enhanced reduced-motion handling

---

## 1. Semantic tree review

### Interactive elements

- [ ] All interactive elements expose semantic labels
- [ ] Buttons describe action intent clearly
- [ ] Icon-only buttons include meaningful labels (`tooltip`, `semanticLabel`, or `Semantics`)
- [ ] Toggle controls expose state correctly
- [ ] Sliders expose current values correctly
- [ ] Form fields expose labels and hints correctly

### Semantic structure

- [ ] Semantic hierarchy matches visual hierarchy
- [ ] Headings exposed appropriately
- [ ] Grouped content uses semantic grouping (`MergeSemantics` where appropriate)
- [ ] Reading order logical and predictable
- [ ] Important content not skipped by screen readers

### Decorative elements

- [ ] Decorative images marked `excludeFromSemantics: true`
- [ ] Decorative icons excluded appropriately
- [ ] Duplicate semantic announcements avoided
- [ ] Background visuals do not pollute semantic tree

### Custom widgets

- [ ] Custom widgets expose semantic properties (`Semantics` wrapper)
- [ ] Reusable design-system components include accessibility support
- [ ] Gesture-based widgets expose semantic actions where applicable
- [ ] Semantic wrappers used appropriately — not redundant nested semantics

---

## 2. Screen reader review

### TalkBack / VoiceOver

- [ ] Tested with TalkBack (Android) where possible
- [ ] Tested with VoiceOver (iOS) where possible
- [ ] Navigation announced correctly
- [ ] Actions announced correctly
- [ ] State changes announced correctly
- [ ] Errors announced correctly
- [ ] Dialogs announced correctly
- [ ] Snackbars/toasts announced correctly
- [ ] Dynamic content changes announced (`SemanticsService.announce`) where UI updates without focus move

### Reading order

- [ ] Reading order matches visual layout
- [ ] Traversal predictable
- [ ] No skipped interactive controls
- [ ] No duplicated announcements

### Navigation

- [ ] Focus moves appropriately after navigation
- [ ] Focus restored appropriately when dialogs close
- [ ] Newly displayed content receives focus correctly
- [ ] Route transitions accessible (go_router surfaces)

---

## 3. Keyboard & focus review

### Keyboard navigation

- [ ] Full UI navigable by keyboard on web (and desktop targets if supported)
- [ ] Keyboard shortcuts documented where applicable
- [ ] No inaccessible hover-only interactions
- [ ] Menus keyboard accessible

### Focus traversal

- [ ] Tab order logical
- [ ] Focus traversal predictable
- [ ] `FocusTraversalGroup` used where appropriate
- [ ] `FocusTraversalOrder` used intentionally
- [ ] No unintended focus traps
- [ ] Focus indicators visible on all interactive elements

### Modal behavior

- [ ] Dialogs trap focus correctly while open
- [ ] Bottom sheets manage focus correctly
- [ ] Focus restored after closing overlays
- [ ] Escape/back navigation works correctly

---

## 4. Touch target & interaction review

### Touch targets

- [ ] Interactive elements ≥ 48×48 logical pixels
- [ ] Dense layouts remain accessible (`IconButton`, `constraints`, padding)
- [ ] Touch targets do not overlap in ways that block activation
- [ ] Gestures forgiving and usable

### Gesture accessibility

- [ ] Gestures have accessible alternatives
- [ ] Drag interactions accessible where possible
- [ ] Long-press interactions discoverable
- [ ] Swipe-only interactions avoided unless necessary and documented

### Interaction safety

- [ ] Destructive actions confirmed
- [ ] Accidental taps minimized
- [ ] Interactive states visually clear
- [ ] Disabled states distinguishable (not only by color)

---

## 5. Text scaling & typography review

### Text scaling

- [ ] Tested at 2.0× text scale (`MediaQuery.textScaleFactorOf`)
- [ ] Tested at extreme accessibility sizes when feasible
- [ ] No clipping of critical content
- [ ] No overflow hiding critical content
- [ ] No truncated critical content without accessible alternative

### Layout resilience

- [ ] Layout adapts to larger text
- [ ] Fixed-height containers avoided for text content
- [ ] Flexible layouts used (`Expanded`, `Flexible`, scroll views)
- [ ] Scrollable fallback exists where needed
- [ ] Text scale factor not capped or overridden (per `docs/RESPONSIVENESS.md`)

### Typography

- [ ] `Theme.of(context).textTheme` used — no hardcoded `TextStyle` font sizes in features
- [ ] No inaccessible small text
- [ ] Line height readable
- [ ] Text spacing accessible

---

## 6. Color & contrast review

### Contrast

- [ ] WCAG 2.1 AA contrast met
- [ ] Normal text ≥ 4.5:1
- [ ] Large text ≥ 3:1
- [ ] Icons/controls ≥ 3:1 against relevant background
- [ ] Disabled states remain understandable

### Color usage

- [ ] Information not conveyed by color alone
- [ ] Status indicators include text/icons/patterns
- [ ] Semantic colors from `Theme.of(context).colorScheme` or design-system tokens — no hardcoded `Color(0xFF...)` in feature code
- [ ] Hardcoded colors avoided

### Visual accessibility

- [ ] Focus indicators visible
- [ ] Error states visually obvious
- [ ] Selected states distinguishable
- [ ] Hover/focus/pressed states accessible (web)

---

## 7. Dark mode review

### Theme safety

- [ ] All screens verified in dark mode
- [ ] No hardcoded light-only colors
- [ ] Contrast valid in dark theme
- [ ] Images/icons visible in dark mode

### Dynamic theming

- [ ] Semantic theme tokens used (`colorScheme`, design system)
- [ ] Surface elevation handled correctly
- [ ] Text readable on all surfaces
- [ ] Overlay/dialog contrast acceptable

---

## 8. Responsive & adaptive accessibility review

### Screen sizes

- [ ] Small phones supported
- [ ] Tablets supported
- [ ] Landscape supported
- [ ] Foldable layouts considered where relevant

### Desktop/web accessibility

- [ ] Mouse + keyboard support works
- [ ] Hover interactions not required for core tasks
- [ ] Focus states visible
- [ ] Resizable layouts remain accessible

---

## 9. Forms accessibility review

### Labels & inputs

- [ ] Inputs have visible or semantic labels
- [ ] Required fields identified (semantics + visual)
- [ ] Hints/help text accessible
- [ ] Placeholder-only labels avoided

### Validation

- [ ] Errors announced accessibly (semantics + visible text)
- [ ] Validation messages understandable (localized, user-friendly)
- [ ] Validation timing appropriate
- [ ] Error recovery clear

### Autofill & input types

- [ ] Correct keyboard/`TextInputType` used
- [ ] Autofill hints provided where appropriate
- [ ] Password fields handled accessibly

---

## 10. Animation & motion review

### Motion accessibility

- [ ] Excessive motion avoided
- [ ] Motion not required for understanding
- [ ] Reduced-motion preferences respected where possible (`MediaQuery.disableAnimations`)

### Animation safety

- [ ] Flashing content avoided (seizure risk)
- [ ] Rapid motion avoided
- [ ] Animations do not block interaction
- [ ] Transitions remain comprehensible

---

## 11. Error & state accessibility review

Align with `AsyncValue` / loading-error-empty patterns in `docs/UI.md`.

### Loading states

- [ ] Loading states announced appropriately where status matters
- [ ] Progress indicators accessible (`Semantics` on `CircularProgressIndicator` / linear progress)
- [ ] Skeleton loaders not confused with real content (labels or `excludeFromSemantics` as appropriate)

### Error states

- [ ] Errors announced clearly
- [ ] Recovery actions accessible (retry buttons labeled)
- [ ] Retry actions keyboard/screen-reader accessible

### Empty states

- [ ] Empty states understandable (guidance text, not blank screen)
- [ ] Next-step guidance accessible

---

## 12. Accessibility testing review

### Manual testing

- [ ] Manual accessibility review completed for scoped UI
- [ ] Critical flows tested with assistive technology where possible
- [ ] Accessibility tested on physical devices when feasible

### Automated testing

- [ ] Analyzer/custom lint passes (no unjustified a11y suppressions)
- [ ] Semantic assertions in widget tests where behavior is critical
- [ ] Golden tests account for text scaling where layout is sensitive (`MediaQuery` text scale in test harness per `docs/RESPONSIVENESS.md`)

---

## 13. Common accessibility anti-patterns

### MUST NOT

- [ ] Hardcode tiny font sizes outside theme
- [ ] Use color alone to convey meaning
- [ ] Create keyboard traps (unintended)
- [ ] Hide interactive elements from semantics without accessible alternative
- [ ] Use inaccessible gesture-only interactions for required tasks
- [ ] Use placeholder-only form labels
- [ ] Break layout at large text scales
- [ ] Suppress focus indicators
- [ ] Cap or ignore `textScaleFactor` to “fix” layout

### SHOULD AVOID

- [ ] Excessively nested semantics
- [ ] Duplicate announcements
- [ ] Ambiguous button labels (“OK”, “Submit” without context)
- [ ] Unlabeled icons
- [ ] Tiny touch targets
- [ ] Fixed-height text containers
- [ ] Raw exception strings as error UI (hurts comprehension for all users)

---

## Review output format

Structure findings as:

```markdown
## Summary

<1–3 sentences: scope reviewed, platforms considered, overall a11y verdict>

## MUST

Blocking accessibility issues.

### <short title>

- **Files:** `path/to/file.dart`, …
- **User impact:** …
- **Reasoning:** …
- **Suggested fix:** …

## SHOULD

Important accessibility improvements.

### <short title>

- **Files:** …
- **User impact:** …
- **Reasoning:** …
- **Suggested fix:** …

## NICE TO HAVE

Optional accessibility enhancements.

### <short title>

- **Files:** …
- **User impact:** …
- **Reasoning:** …
- **Suggested fix:** …

## Testing notes

What was verified statically vs on device/emulator (TalkBack, VoiceOver, keyboard, 2.0× text, dark mode).

## Verdict

Pass | Fail (MUST items present) | Pass with SHOULD follow-ups
```

Each finding must include: issue description, severity, affected file(s), user impact, suggested fix.

Do not omit MUST items when they exist. Do not label style preferences as MUST unless they violate WCAG, governance, or block assistive technology.
