# Responsiveness

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **RESPONSIVENESS.md** > inline comments.
>
> **AI agents — read this file when:** building layouts for different screen sizes, handling orientation changes, implementing adaptive UI, or ensuring accessibility compliance for sizing and touch targets.

---

## Breakpoint definitions

### Standard breakpoints

| Breakpoint | Width | Typical devices |
|-----------|-------|-----------------|
| **Compact** | < 600 dp | Phones (portrait) |
| **Medium** | 600–839 dp | Phones (landscape), small tablets |
| **Expanded** | 840–1199 dp | Tablets, large phones (landscape) |
| **Large** | 1200+ dp | Desktop, large tablets (landscape) |

These align with Material 3's canonical breakpoints.

### Implementation

Define breakpoints as constants in `packages/design_system/`:

```dart
abstract final class EddyBreakpoints {
  static const double compact = 0;
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;
}
```

### Usage pattern

```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= EddyBreakpoints.expanded) {
        return const ExpandedLayout();
      } else if (constraints.maxWidth >= EddyBreakpoints.medium) {
        return const MediumLayout();
      }
      return const CompactLayout();
    },
  );
}
```

---

## LayoutBuilder / MediaQuery usage

### LayoutBuilder (preferred for widget-level sizing)

Use `LayoutBuilder` when the widget needs to adapt based on **available space** (its parent's constraints):

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isWide = constraints.maxWidth >= EddyBreakpoints.medium;
    return isWide
      ? Row(children: [sidebar, Expanded(child: content)])
      : Column(children: [content]);
  },
);
```

### MediaQuery (for screen-level concerns)

Use `MediaQuery` for:
- Screen-level breakpoints when `LayoutBuilder` is not in scope
- Text scale factor (`MediaQuery.textScaleFactorOf(context)`)
- Safe area insets (`MediaQuery.paddingOf(context)`)
- Device pixel ratio
- Keyboard visibility (`MediaQuery.viewInsetsOf(context)`)

```dart
final screenWidth = MediaQuery.sizeOf(context).width;
final textScale = MediaQuery.textScaleFactorOf(context);
final bottomInset = MediaQuery.paddingOf(context).bottom;
```

### Prefer `.of` static methods

Use the targeted static methods (`MediaQuery.sizeOf`, `MediaQuery.paddingOf`) over `MediaQuery.of(context)` to avoid unnecessary rebuilds when unrelated media query properties change.

---

## Adaptive vs. responsive distinction

| Concept | Meaning | Example |
|---------|---------|---------|
| **Responsive** | Same component adjusts its layout/size for available space | A card grid that shows 1, 2, or 3 columns based on width |
| **Adaptive** | Different component or interaction model for different platforms or form factors | `NavigationBar` on phone, `NavigationRail` on tablet, `NavigationDrawer` on desktop |

### Rules

1. **Most widgets should be responsive** — they adjust layout within the same component tree.
2. **Adaptive switching** is reserved for fundamentally different interaction patterns (navigation, input methods, selection models).
3. Do not build separate "phone" and "tablet" widget trees unless the UX is genuinely different. Prefer responsive adjustments within a single widget.

---

## Platform-adaptive widgets

### When to use platform-adaptive components

| Component | Compact (phone) | Expanded (tablet/desktop) |
|-----------|-----------------|--------------------------|
| Navigation | `NavigationBar` (bottom) | `NavigationRail` or `NavigationDrawer` |
| Lists | Full-screen list | List-detail (master-detail) layout |
| Dialogs | Full-screen or bottom sheet | Centered dialog |
| Selection | Single-select → navigate | Multi-select in-place |

### Implementation

```dart
Widget buildNavigation(BuildContext context, BoxConstraints constraints) {
  if (constraints.maxWidth >= EddyBreakpoints.expanded) {
    return NavigationRail( ... );
  }
  return NavigationBar( ... );
}
```

### Material adaptive components

Prefer Flutter's built-in adaptive constructors where available:
- `Switch.adaptive`
- `Slider.adaptive`
- `CircularProgressIndicator.adaptive`

Use these to get platform-native feel on iOS without maintaining separate widget trees.

---

## Orientation handling

### Rules

1. **Support both orientations** unless a screen has an explicit reason to be locked (e.g., camera viewfinder).
2. **Test in both orientations.** Layout must not overflow or clip in landscape.
3. **Use `LayoutBuilder`**, not `MediaQuery.orientationOf`, for layout decisions. `LayoutBuilder` responds to the actual available space, which is more reliable than orientation alone (split-screen, foldables, etc.).
4. **Scrollable content must remain scrollable** in both orientations. A screen that fits in portrait but overflows in landscape is a bug.

### Landscape considerations

- Map screen: full use of landscape width. Controls may move to the side.
- Detail screens: consider side-by-side layout (conditions + map) in landscape.
- Forms: single-column in portrait, two-column in landscape if width permits.

---

## Text scaling support

### Requirements

1. **All text must use `textTheme` styles** (see `THEMING.md`). These inherit the system text scale factor automatically.
2. **Layout must accommodate text scale factors from 0.8x to 2.0x** without overflow, clipping, or layout breakage.
3. **Do not cap text scale factor.** Respect the user's accessibility setting. If a layout breaks at large text, fix the layout (make it scrollable, wrap text, use `FittedBox` with care).
4. **Test at 2.0x text scale** to verify layouts.

### Common pitfalls

| Pitfall | Fix |
|---------|-----|
| Fixed-height containers with text | Use `IntrinsicHeight`, `Flexible`, or remove height constraint |
| Text overflow in small spaces | Use `maxLines` + `overflow: TextOverflow.ellipsis` or allow wrapping |
| Buttons with fixed width | Use `IntrinsicWidth` or min-width constraints |
| Badge/chip text overflow | Allow multi-line or use `FittedBox` with `minFontSize` |

### Testing

```dart
testWidgets('layout handles large text scale', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaleFactor: 2.0),
      child: MaterialApp(home: LaunchDetailScreen(...)),
    ),
  );
  expect(tester.takeException(), isNull); // no overflow
});
```

---

## Minimum touch target sizes

### Rule

All interactive elements must have a minimum touch target of **48 x 48 logical pixels** (Material 3 accessibility guideline).

### Implementation

```dart
// GOOD: IconButton already meets 48x48 minimum
IconButton(
  onPressed: _onTap,
  icon: const Icon(Icons.info),
);

// GOOD: explicit minimum size for custom tap targets
GestureDetector(
  onTap: _onTap,
  child: ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    child: const Icon(Icons.close, size: 16),
  ),
);

// BAD: small icon without adequate touch target
GestureDetector(
  onTap: _onTap,
  child: const Icon(Icons.close, size: 16), // 16x16 is too small to tap
);
```

### Rules

1. **48x48 is the minimum**, not the target. Larger is better for primary actions.
2. **Adjacent touch targets** should have at least 8dp spacing to prevent mis-taps.
3. **Test with the accessibility inspector** — the `Semantics` debugger shows touch target sizes.
4. **Map pins and markers** on the Mapbox map must be large enough to tap. If the map SDK doesn't enforce minimums, add a transparent hit area.
