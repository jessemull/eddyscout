# EddyScout — Localization Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when adding or modifying user-facing strings; when creating or editing ARB files; when configuring `flutter gen-l10n`; when reviewing code for hardcoded strings; or when adding support for new locales.

---

## No Hardcoded User-Facing Strings

**Every** user-visible string must come from the localization system. This includes:

- Labels, titles, and button text
- Error messages shown to users
- Placeholder and hint text
- Accessibility labels and semantics
- Snackbar and toast messages

Hardcoded user-facing strings in Dart code are a **blocking** review finding.

Exceptions: log messages, debug-only text, and developer-facing assertions.

## ARB File Workflow

Localization uses Flutter's built-in `gen-l10n` tool with ARB (Application Resource Bundle) files.

```
apps/eddyscout/lib/l10n/
├── app_en.arb        # English — source of truth
├── app_es.arb        # Spanish (example)
└── ...
```

- **`app_en.arb`** is the canonical source. All new keys are added here first.
- Translated ARB files must contain the same keys as `app_en.arb`.
- Missing keys in a translated ARB fall back to the English value.

### Adding a new string

1. Add the key and value to `app_en.arb`.
2. Add a `@<key>` metadata entry with a `description` field.
3. Run `flutter gen-l10n`.
4. Use the generated accessor in code: `AppLocalizations.of(context).<key>` or `context.l10n.<key>`.
5. Add translations to other ARB files (or flag for translator review).

## flutter gen-l10n Configuration

Configure in `l10n.yaml` at the app root:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
nullable-getter: false
```

- `synthetic-package: false` — generated code lives in `lib/` for easier imports.
- `nullable-getter: false` — accessors are non-nullable; missing localization setup is a compile error.

## Translation Key Naming

| Rule | Example |
|------|---------|
| **camelCase** | `launchDetailTitle`, `retryButtonLabel` |
| **Descriptive** | `weatherUnavailableMessage` not `msg1` |
| **Screen-prefixed for screen-specific strings** | `mapScreenSearchHint` |
| **Shared strings use generic names** | `cancelButton`, `okButton` |

Avoid abbreviations. Keys should be self-documenting.

## Pluralization Rules

Use ICU `plural` syntax in ARB files:

```json
"launchCount": "{count, plural, =0{No launches} =1{1 launch} other{{count} launches}}",
"@launchCount": {
  "description": "Number of launches found",
  "placeholders": {
    "count": { "type": "int" }
  }
}
```

- Always handle `=0`, `=1`, and `other` cases at minimum.
- For languages with complex plural rules (e.g., Russian, Arabic), add all required plural categories (`zero`, `one`, `two`, `few`, `many`, `other`).

## RTL Support Requirements

- Use `Directionality`-aware widgets and layout properties (`start`/`end` instead of `left`/`right`).
- Test RTL layout when adding RTL locales.
- Use `TextDirection.ltr` explicitly only for content that is always LTR (e.g., code, URLs).
- Icons that imply direction (arrows, back buttons) must flip in RTL contexts.

## Date / Number Formatting

Use the **`intl`** package for all date, time, number, and currency formatting:

```dart
DateFormat.yMMMd(locale).format(date);
NumberFormat.compact(locale: locale).format(value);
```

- Never use `DateTime.toString()` or manual string interpolation for user-facing dates.
- Respect the device locale for default formatting.
- For domain-specific formats (e.g., river flow in cfs), use consistent formatting with appropriate units.

## Localization Testing Strategy

- **Unit tests:** Verify that all ARB keys resolve without errors for every supported locale.
- **Widget tests:** Test screens with multiple locales to catch layout overflow from longer translations.
- **Golden tests (optional):** Capture screenshots per locale for visual regression.
- **CI:** Run `flutter gen-l10n` as part of CI to ensure generated files are in sync.

## Adding New Locales

1. Create a new ARB file: `app_<locale>.arb` (e.g., `app_fr.arb`).
2. Copy all keys from `app_en.arb` and translate.
3. Add the locale to `supportedLocales` in `l10n.yaml` or `MaterialApp` configuration.
4. Run `flutter gen-l10n` and verify no errors.
5. Test critical screens in the new locale for layout issues.
6. Update this document's supported locales list.

### Currently supported locales

- `en` — English (source)

Additional locales will be added as the product expands beyond PNW.
