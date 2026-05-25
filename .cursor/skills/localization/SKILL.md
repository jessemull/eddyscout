---
name: localization
description: >-
  Add and manage localized strings for EddyScout using ARB files and
  flutter gen-l10n. Use when adding UI text, modifying strings, handling
  pluralization, or reviewing localization compliance.
---

# Localization

Read the following before adding or modifying any localized text:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/LOCALIZATION.md`
- `docs/ARCHITECTURE.md`
- `docs/TESTING.md`
- `docs/UI.md`
- `docs/ACCESSIBILITY.md`

Companion skills:
- `accessibility-review` — verify localized text is readable by screen readers
- `testing` — widget test conventions for localized content
- `code-generation` — `flutter gen-l10n` is separate from `build_runner`; see `docs/LOCALIZATION.md`

Localization is a **core architectural concern**, not a UI detail.

All user-facing text must be:
- localized
- testable
- overflow-safe
- context-aware
- plural-safe
- and accessible

---

# When to Use

Use this skill when:

- adding new UI text
- modifying existing strings
- adding error messages
- adding validation messages
- adding labels, hints, placeholders
- adding notifications or snackbars
- adding empty states
- adding onboarding or marketing copy

---

# Core Localization Principles

## No Hardcoded Strings

All user-visible text MUST come from localization files.

Do not allow:
- inline strings in widgets
- hardcoded error messages
- hardcoded labels
- hardcoded UI copy

Exception:
- debug-only tooling text (explicitly marked)

---

## Localization Is a Data Model

Treat localization keys as:
- stable APIs
- contract-bound identifiers
- versioned interfaces between UI and language

Changing a key is a breaking change.

---

## Keys Must Be Meaningful

Keys must describe:
- intent
- context
- usage domain

Avoid:
- generic keys (`text1`, `label2`)
- UI-position-based names (`buttonTopLeft`)
- ambiguous names (`title`, `message` without context)

Prefer:
- `loginSubmitButton`
- `networkErrorMessage`
- `emptyCartState`

---

# 1. Add Key to ARB File

## Source of Truth

- [ ] all base strings go in `lib/l10n/app_en.arb`

## Key Rules

- [ ] camelCase keys only
- [ ] descriptive naming required
- [ ] consistent domain grouping
- [ ] no duplicate semantics

## Example Structure

```json
{
  "riverFlowRate": "Flow rate: {rate} cfs",
  "@riverFlowRate": {
    "description": "Displays the river flow rate in cubic feet per second",
    "placeholders": {
      "rate": {
        "type": "String"
      }
    }
  }
}
```

## Required Metadata

Every key must include:

- [ ] `description` (mandatory)
- [ ] `placeholders` (if dynamic values exist)

---

# 2. Placeholder Rules

## Naming

- [ ] placeholders must be descriptive (`userName`, `itemCount`)
- [ ] avoid generic placeholders (`value`, `x`)

## Types

- [ ] ensure correct type mapping (String, int, double)
- [ ] avoid implicit type casting in UI layer

## Safety

- [ ] no HTML or markup in placeholders unless explicitly supported
- [ ] no concatenation of localized strings in code

---

# 3. Pluralization (ICU Syntax)

Use ICU plural rules for all count-based text.

## Example

```json
{
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}"
}
```

## Rules

- [ ] always include =0, =1, and other cases where applicable
- [ ] test boundary values explicitly
- [ ] ensure grammatical correctness per locale
- [ ] avoid constructing plurals in Dart code

---

# 4. Code Generation

Run localization generation:

```bash
flutter gen-l10n
```

## Validation

- [ ] generation completes without errors
- [ ] `AppLocalizations` updated correctly
- [ ] no missing keys
- [ ] no stale references

If generation fails:
- fix ARB file first
- do not patch generated files manually

---

# 5. Usage in Widgets

## Access Pattern

- [ ] always use `AppLocalizations.of(context)!`
- [ ] never cache localized strings globally
- [ ] never store localized strings in state

## Correct Usage

```dart
AppLocalizations.of(context)!.loginSubmitButton
```

With parameters:

```dart
AppLocalizations.of(context)!.riverFlowRate(flowValue)
```

## Incorrect Usage

- storing localized strings in providers
- passing raw strings across layers
- concatenating strings in UI code

---

# 6. Overflow & Layout Safety

Localized strings must assume:

- longer translations
- different word ordering
- expanded text length in other languages

## Required Checks

- [ ] no text overflow in UI
- [ ] use flexible layouts (`Expanded`, `Flexible`)
- [ ] avoid fixed-width constraints for text
- [ ] test long string scenarios

---

# 7. State & Architecture Rules

- [ ] localization stays in presentation layer only
- [ ] domain layer never depends on localization
- [ ] data layer never depends on localization
- [ ] error messages from backend must be mapped to localized UI strings

---

# 8. Testing Requirements

## Widget Tests

- [ ] verify localized text renders correctly
- [ ] verify placeholders populate correctly
- [ ] verify plural cases
- [ ] verify fallback behavior if applicable

## Locale Testing

Where multi-language support exists:

- [ ] test at least 2 locales
- [ ] verify layout stability across locales
- [ ] verify no clipping or overflow

---

# 9. Accessibility Considerations

- [ ] localized text is readable by screen readers
- [ ] semantic labels are localized where appropriate
- [ ] no missing labels in non-English locales

---

# 10. Common Anti-Patterns

## MUST NOT

- [ ] hardcode user-facing strings
- [ ] concatenate localized strings in Dart
- [ ] store localized strings in state/providers
- [ ] bypass ARB system
- [ ] edit generated localization code

## SHOULD AVOID

- [ ] overly long keys
- [ ] ambiguous key naming
- [ ] mixing formatting logic into localization
- [ ] duplicating similar strings across keys

---

# 11. Validation Checklist

Before committing:

- [ ] ARB updated
- [ ] localization generated
- [ ] no missing keys
- [ ] UI renders correctly
- [ ] no overflow issues
- [ ] tests pass
- [ ] preflight passes

Run:

```bash
make preflight
```

---

# 12. Output Expectations

When performing localization work, provide:

## Change Summary
- keys added/modified/removed
- affected screens/features

## Localization Design Notes
- rationale for key naming
- placeholder design decisions
- pluralization logic

## Risk Assessment
- overflow risks
- translation expansion risks
- missing context risks

## Validation Results
- generation status
- test coverage status
- UI rendering confirmation
