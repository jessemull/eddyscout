# Theming

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **THEMING.md** > inline comments.
>
> **AI agents — read this file when:** defining colors, typography, spacing, or theme tokens; implementing dark mode; creating custom theme extensions; or reviewing theme-related code.

---

## Material 3 ColorScheme.fromSeed

### Rule

All colors derive from `ColorScheme.fromSeed`. Do not manually define a full `ColorScheme`.

```dart
// GOOD
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: EddyColors.primarySeed,
    brightness: Brightness.light,
  ),
);

// BAD: manually specifying every color
ThemeData(
  colorScheme: ColorScheme(
    primary: Color(0xFF...),
    secondary: Color(0xFF...),
    // ... 20+ manual colors
  ),
);
```

### Seed color

The seed color should reflect EddyScout's brand — a PNW-inspired palette (water, forest, mountain tones). Define the seed in `packages/design_system/` as a constant.

---

## Semantic color tokens

### Rule

Always reference colors by their semantic role, never by their visual value.

```dart
// GOOD: semantic reference
final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;
final errorText = Theme.of(context).colorScheme.error;

// BAD: hardcoded color
final cardColor = Color(0xFFF5F5F5);
final errorText = Colors.red;
```

### Common semantic tokens

| Token | Usage |
|-------|-------|
| `primary` | Primary actions, active elements, links |
| `onPrimary` | Text/icons on primary-colored surfaces |
| `secondary` | Secondary actions, less prominent elements |
| `surface` | Card backgrounds, dialogs, sheets |
| `surfaceContainerHighest` | Elevated card surfaces |
| `error` | Error states, destructive actions |
| `onSurface` | Primary text and icons |
| `onSurfaceVariant` | Secondary text, subtle icons |
| `outline` | Borders, dividers |
| `outlineVariant` | Subtle borders |

### Go/No-Go semantic colors

For the Go/No-Go verdict display, define custom semantic tokens via theme extensions (see below), not hardcoded green/yellow/red:

| Verdict | Token name | Light mode | Dark mode |
|---------|-----------|------------|-----------|
| Go | `goColor` | Derived from green seed | Adjusted for dark |
| Marginal | `marginalColor` | Derived from amber seed | Adjusted for dark |
| No-Go | `noGoColor` | Derived from red seed | Adjusted for dark |
| Insufficient data | `insufficientDataColor` | `onSurfaceVariant` | `onSurfaceVariant` |

---

## Spacing scale

### Rule

Use a consistent spacing scale. Do not use arbitrary pixel values.

### Scale

Define spacing constants in `packages/design_system/`:

| Token | Value | Usage |
|-------|-------|-------|
| `EddySpacing.xxs` | 2 | Tight internal padding |
| `EddySpacing.xs` | 4 | Icon-to-text gaps, tight margins |
| `EddySpacing.sm` | 8 | Default internal padding |
| `EddySpacing.md` | 16 | Standard section spacing, card padding |
| `EddySpacing.lg` | 24 | Section separation, major gaps |
| `EddySpacing.xl` | 32 | Screen-level padding, major separators |
| `EddySpacing.xxl` | 48 | Large visual breaks |

```dart
// GOOD
Padding(padding: const EdgeInsets.all(EddySpacing.md));
SizedBox(height: EddySpacing.sm);

// BAD: magic numbers
Padding(padding: const EdgeInsets.all(13));
SizedBox(height: 7);
```

---

## Typography scale

### Rule

All text styles come from `Theme.of(context).textTheme`. No inline `TextStyle` constructors with hardcoded sizes or fonts.

```dart
// GOOD
Text('Willamette Park', style: Theme.of(context).textTheme.headlineSmall);

// BAD
Text('Willamette Park', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
```

### M3 type scale

Use the standard Material 3 type roles:

| Role | Typical use |
|------|-------------|
| `displayLarge/Medium/Small` | Hero text, splash screens |
| `headlineLarge/Medium/Small` | Screen titles, section headers |
| `titleLarge/Medium/Small` | Card titles, list item titles |
| `bodyLarge/Medium/Small` | Body text, descriptions |
| `labelLarge/Medium/Small` | Buttons, chips, badges |

### Custom font

If EddyScout uses a custom font, configure it in `ThemeData.textTheme` and `ThemeData.primaryTextTheme` via `GoogleFonts` or bundled assets. Never apply font family inline.

---

## Dark mode requirements

### Mandatory support

EddyScout must support both light and dark themes. The app follows the system setting by default with an optional in-app override.

### Implementation

```dart
MaterialApp(
  theme: EddyTheme.light(),
  darkTheme: EddyTheme.dark(),
  themeMode: ref.watch(themeModeProvider), // system, light, or dark
);
```

### Rules

1. **Every screen must be tested in both themes.** Widget tests should run with both light and dark `ThemeData`.
2. **No hardcoded colors.** All colors come from `ColorScheme` or custom theme extensions, which define both light and dark variants.
3. **Images and icons** that look wrong on dark backgrounds need dark-mode variants or use adaptive colors.
4. **Map tiles:** Mapbox supports dark style. The map style should switch with the app theme.
5. **Contrast ratios must be met in both themes.**

---

## No hardcoded colors

### Rule

Never use `Color(0xFF...)`, `Colors.blue`, or any literal color value in widget code.

### Where colors are defined

- `ColorScheme.fromSeed` for standard M3 tokens
- `ThemeExtension` subclasses for app-specific tokens (Go/No-Go verdicts, etc.)
- `packages/design_system/lib/src/theme/` for all color definitions

### Enforcement

The `very_good_analysis` lint set and custom lint rules should flag hardcoded colors. Code review catches anything lint misses.

---

## No hardcoded text styles

### Rule

Never construct `TextStyle` with inline `fontSize`, `fontWeight`, or `fontFamily` in widget code.

```dart
// GOOD
style: Theme.of(context).textTheme.bodyMedium

// GOOD: minor modification on a theme style
style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.error)

// BAD
style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
```

### Exception

`copyWith` on a theme text style is acceptable for one-off modifications (color, decoration). Do not override `fontSize` or `fontWeight` via `copyWith` — if you need a different size, use a different type role.

---

## Custom theme extensions for app-specific tokens

### When to use

When the app needs semantic tokens that Material 3's `ColorScheme` and `TextTheme` don't cover.

### Implementation

```dart
class EddyColors extends ThemeExtension<EddyColors> {
  const EddyColors({
    required this.goColor,
    required this.marginalColor,
    required this.noGoColor,
    required this.insufficientDataColor,
    required this.waterOverlay,
  });

  final Color goColor;
  final Color marginalColor;
  final Color noGoColor;
  final Color insufficientDataColor;
  final Color waterOverlay;

  @override
  EddyColors copyWith({ ... }) => EddyColors( ... );

  @override
  EddyColors lerp(EddyColors? other, double t) => EddyColors(
    goColor: Color.lerp(goColor, other?.goColor, t)!,
    // ... lerp all fields
  );

  static EddyColors of(BuildContext context) =>
    Theme.of(context).extension<EddyColors>()!;
}
```

### Usage

```dart
final colors = EddyColors.of(context);
Container(color: colors.goColor);
```

### Rules

1. Register extensions in both light and dark `ThemeData`:
   ```dart
   ThemeData(extensions: [EddyColors.light(), EddyColors.dark()]);
   ```
2. Every custom color has both light and dark variants.
3. Access via the `.of(context)` static helper, not raw `Theme.of(context).extension`.
4. Custom extensions live in `packages/design_system/lib/src/theme/`.
