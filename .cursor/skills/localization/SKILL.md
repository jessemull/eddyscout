# Localization

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when adding, modifying, or auditing localized strings in the app.

## References

- `docs/LOCALIZATION.md` — localization conventions, key naming, plural rules

## Checklist

### 1. Add Key to ARB File

- [ ] Open `lib/l10n/app_en.arb` (English is the source of truth)
- [ ] Add the new key with a descriptive, camelCase name
- [ ] Add `@<key>` metadata with a `description` field
- [ ] Example:
  ```json
  "riverFlowRate": "Flow rate: {rate} cfs",
  "@riverFlowRate": {
    "description": "Displays the river flow rate in cubic feet per second",
    "placeholders": {
      "rate": { "type": "String" }
    }
  }
  ```

### 2. Handle Pluralization

- [ ] Use ICU plural syntax for countable items
- [ ] Example:
  ```json
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}"
  ```
- [ ] Test with 0, 1, and plural values

### 3. Generate Localization Code

```bash
flutter gen-l10n
```

- [ ] Run `flutter gen-l10n` to generate the `AppLocalizations` class
- [ ] Verify no generation errors in the output

### 4. Use in Widgets

- [ ] Access via `AppLocalizations.of(context)!.keyName`
- [ ] Never use hardcoded strings for user-visible text
- [ ] Pass parameters for dynamic content:
  ```dart
  AppLocalizations.of(context)!.riverFlowRate(flowValue)
  ```

### 5. Test

- [ ] Widget tests verify localized strings render correctly
- [ ] Test with different locales if multi-language support is active
- [ ] Verify text does not overflow with longer translations
- [ ] Run `make preflight`
