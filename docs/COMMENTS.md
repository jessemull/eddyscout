# Comments

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **COMMENTS.md** > inline comments.
>
> **AI agents — read this file when:** writing code comments, reviewing comments in PRs, deciding whether a comment is necessary, or writing documentation comments for public APIs.

---

## Philosophy: comments are maintenance cost

Every comment is a liability. It must be read, understood, and kept in sync with the code it describes. When code changes and comments don't, they become misleading — worse than no comment at all.

The goal is **minimal, high-value commenting** — enough to capture intent that the code cannot express, and nothing more.

---

## Comment minimization principles

1. **Code is the primary documentation.** Names, types, structure, and tests should convey what the code does and why.
2. **If you need a comment to explain what code does, the code should be clearer.** Rename the variable, extract the function, simplify the logic.
3. **Comments explain _why_, not _what_.** The code already says _what_. Comments should capture the intent, constraint, or trade-off that isn't visible in the code itself.
4. **Every comment must earn its keep.** If removing a comment would not reduce a reader's understanding, remove it.

---

## Self-documenting code expectations

Before writing a comment, exhaust these alternatives:

- **Rename.** A well-named function, variable, or class eliminates the need for a comment. `calculateWindChill` needs no comment; `calc` does.
- **Extract.** A complex block with a comment can often become a named function whose name replaces the comment.
- **Type.** Use specific types — `Duration` instead of `int` with a comment "in milliseconds."
- **Simplify.** If the logic is too complex to understand without a comment, the logic may be too complex.
- **Test.** Tests document behavior. A test named `returns_no_go_when_wind_exceeds_threshold` explains the rule better than a code comment.

---

## Comment decision tree

```
Is the intent non-obvious from the code alone?
├── No → Do not comment.
└── Yes → Can you make it obvious by renaming, extracting, or simplifying?
    ├── Yes → Refactor first. Re-evaluate.
    └── No → Is it one of the required comment categories (below)?
        ├── Yes → Write a concise comment explaining WHY.
        └── No → Is it a public API?
            ├── Yes → Write a /// doc comment.
            └── No → Strongly consider not commenting.
                      If you still feel it's needed, write
                      the shortest comment that captures the
                      non-obvious intent.
```

---

## Banned comment patterns

These comments add noise and must not appear in the codebase. Remove them on sight.

### Narration comments

```dart
// BAD: narrates what the code does
final user = getUser(); // Get the user
items.add(item); // Add the item to the list
return result; // Return the result
```

### Obvious comments

```dart
// BAD: restates the code in English
// Check if the list is empty
if (items.isEmpty) { ... }

// BAD: restates the type or name
/// The name of the launch.
final String name;
```

### Section dividers without value

```dart
// BAD: meaningless separators
// ============ METHODS ============
// --- Private helpers ---
// *** IMPORTANT ***
```

### Commented-out code

```dart
// BAD: dead code in comments — use version control
// final oldValue = computeOld();
// if (legacyMode) { ... }
```

### TODOs without tickets

```dart
// BAD: untracked work
// TODO: fix this later
// FIXME: something is wrong here
// HACK: temporary workaround
```

**Acceptable TODO format:** `// TODO(<person-or-team>): <description> — <issue-link>` — and the issue must exist.

### Change-log comments

```dart
// BAD: use git history, not inline changelogs
// Added by Jesse on 2025-01-15
// Changed to use Riverpod in PR #42
```

---

## Required comment categories

These situations **require** a comment because the code alone cannot convey the reasoning:

### Architecture decisions

When the code structure reflects a deliberate choice between alternatives:

```dart
// Uses separate providers for each condition type rather than a single
// combined provider. This prevents a tide-fetch failure from blocking
// weather display — each condition degrades independently.
```

### Security constraints

When code exists specifically for security and removing it would look like a safe simplification:

```dart
// Redact token from error logs — even in debug, tokens must not appear
// in console output per SECURITY.md.
```

### Platform quirks and workarounds

When code works around a framework, OS, or third-party library issue:

```dart
// Mapbox on Android emits duplicate onStyleLoaded callbacks. Guard
// against re-initialization. See: github.com/mapbox/mapbox-maps-flutter/issues/XXX
```

### Performance trade-offs

When code is intentionally less readable for performance:

```dart
// Pre-compute gauge-to-launch index at startup rather than per-frame
// lookup. Launch count is bounded (~50 in PNW), so the map is small
// and startup cost is negligible vs. per-frame linear scan.
```

### Non-obvious intent

When the code is correct but looks wrong, or when deleting it would seem safe:

```dart
// Intentionally using >= instead of > here: a flow exactly at the
// upper band limit is "marginal," not "too high," per the evaluator
// spec in decision/go_no_go_thresholds.dart.
```

### Legal or compliance

```dart
// NOAA data attribution required per terms of service.
// USGS provisional data disclaimer — do not remove.
```

---

## Formatting standards

### Inline comments (`//`)

- One space after `//`.
- Sentence case, no trailing period for single-line comments.
- Place above the code they describe, not at the end of the line (unless very short and closely coupled).
- Wrap at the same line length as code (80 characters preferred).

```dart
// Guard against null wind when the NWS response omits the field
final windSpeed = rawWind ?? 0.0;
```

### Block comments

Avoid block comments (`/* */`). Use multiple `//` lines instead. Block comments don't nest and are harder to manage.

---

## Documentation comments (`///`)

### When required

- **Every public class, function, method, property, and typedef** in packages (`packages/*`). These are library APIs consumed by other packages and the app.
- **Not required** for private members, app-internal code, or obvious overrides.

### Format

```dart
/// Evaluates current conditions against the user's skill profile and
/// returns a [GoNoGoResult] with a verdict and contributing factors.
///
/// Returns [GoNoGoVerdict.insufficientData] if critical conditions
/// (wind speed, flow rate) are unavailable.
GoNoGoResult evaluate(ConditionsSnapshot conditions, SkillProfile profile);
```

### Rules

- First line is a single sentence summarizing what it does (imperative mood).
- Additional paragraphs explain behavior, edge cases, or important constraints.
- Use `[ClassName]` and `[methodName]` for cross-references.
- Document parameters only when their purpose is non-obvious from the name and type.
- Document return values when the range or meaning is not obvious.
- Document exceptions/errors that callers should handle.
- Do not restate the type signature in prose.

---

## Comment budget

Think of comments as having a cost. Each comment:

- Must be read by every future reader
- Must be maintained when code changes
- Competes for attention with other comments

If a file has more comment lines than code lines, something is wrong. Either the code is too complex (simplify it) or the comments are too verbose (cut them).

**Target: comments should be < 10% of total lines in most files.** Exceptions: files with significant platform workarounds or complex algorithms.
