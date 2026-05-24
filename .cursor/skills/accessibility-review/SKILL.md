# Accessibility Review

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when auditing or implementing accessibility (a11y) for widgets and screens.

## References

- `docs/ARCHITECTURE.md` — widget design guidelines
- Material 3 accessibility guidelines

## Checklist

### 1. Semantics Widgets

- [ ] All interactive elements have `Semantics` labels
- [ ] Images have `semanticLabel` or are marked `excludeFromSemantics`
- [ ] Custom widgets expose semantic properties via `Semantics` wrapper
- [ ] Decorative elements are excluded from the semantic tree

### 2. Touch Targets

- [ ] All tappable elements are at least 48×48 dp
- [ ] Use `MaterialButton`, `IconButton`, or `InkWell` with `constraints`
- [ ] Verify with DevTools widget inspector

### 3. Screen Reader Testing

- [ ] Test with TalkBack (Android) and VoiceOver (iOS)
- [ ] Verify logical reading order matches visual layout
- [ ] Confirm all actions are announced correctly
- [ ] Check that focus moves to new content after navigation

### 4. Text Scaling

- [ ] Test at 2× text scale (`MediaQuery.textScaleFactorOf`)
- [ ] Verify no text overflow or clipping
- [ ] Use flexible layouts (`Expanded`, `Flexible`) instead of fixed heights
- [ ] Avoid hardcoded `fontSize` — use theme text styles

### 5. Focus Traversal

- [ ] Tab order follows logical reading order
- [ ] `FocusTraversalGroup` and `FocusTraversalOrder` used where needed
- [ ] No focus traps — user can always navigate away
- [ ] Modal dialogs trap focus correctly and release on close

### 6. Color Contrast

- [ ] Text meets WCAG AA contrast ratio (4.5:1 normal, 3:1 large)
- [ ] Icons and controls meet 3:1 contrast against background
- [ ] Use theme colors from `SemanticColors` — never hardcode
- [ ] Information is not conveyed by color alone (add icons or text)

### 7. Dark Mode

- [ ] All screens render correctly in dark theme
- [ ] No hardcoded light-only colors
- [ ] Verify contrast ratios in both themes
