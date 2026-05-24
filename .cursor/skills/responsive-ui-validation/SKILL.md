# Responsive UI Validation

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when building or validating UI layouts across different screen sizes and orientations.

## References

- `docs/RESPONSIVENESS.md` — breakpoints, layout patterns, responsive guidelines

## Breakpoints

| Category | Width | Examples |
|----------|-------|---------|
| Phone (portrait) | < 600dp | Most Android/iOS phones |
| Phone (landscape) | < 600dp height | Rotated phones |
| Tablet (portrait) | 600–839dp | iPad Mini, small tablets |
| Tablet (landscape) | 840–1199dp | iPad, Android tablets |
| Desktop | ≥ 1200dp | Web, ChromeOS |

## Checklist

### 1. Test at Multiple Breakpoints

- [ ] Phone portrait (360×640, 390×844, 414×896)
- [ ] Phone landscape
- [ ] Tablet portrait (768×1024)
- [ ] Tablet landscape (1024×768)
- [ ] Desktop / wide (1440×900)

### 2. Use Responsive Layout Widgets

- [ ] `LayoutBuilder` for parent-size-aware layouts
- [ ] `MediaQuery` for screen-level dimensions
- [ ] `Expanded` / `Flexible` instead of fixed widths
- [ ] `FractionallySizedBox` for proportional sizing
- [ ] `Wrap` instead of `Row` when items might overflow

### 3. Verify Orientation Changes

- [ ] Rotate device/emulator and verify layout adjusts
- [ ] State is preserved across orientation changes
- [ ] No overflow errors in landscape mode
- [ ] Scrollable content remains accessible

### 4. Check Text Scaling

- [ ] Test at 1× (default), 1.5×, and 2× text scale
- [ ] No text clipping or overflow at 2× scale
- [ ] Use theme text styles, not hardcoded `fontSize`
- [ ] Flexible containers expand to fit scaled text

### 5. Test Touch Targets on Mobile

- [ ] All tappable elements ≥ 48×48 dp
- [ ] Adequate spacing between touch targets
- [ ] Bottom navigation and FABs are reachable with one hand
- [ ] Verify on small phone sizes (360dp width)

### 6. Validate

- [ ] Run widget tests at different surface sizes using `tester.binding.window`
- [ ] Consider golden tests for key breakpoints
- [ ] Run `make preflight`
