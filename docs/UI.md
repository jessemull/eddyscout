# UI

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **UI.md** > inline comments.
>
> **AI agents — read this file when:** building widgets, choosing between Stateless/Stateful, designing screens, implementing loading/error states, or reviewing widget code.

---

## Material 3 as design language

EddyScout uses Material 3 (Material You) as its design foundation:

- `useMaterial3: true` in `ThemeData`.
- Use M3 components: `FilledButton`, `OutlinedButton`, `SearchBar`, `NavigationBar`, `Card.filled`, etc.
- Follow M3 spacing, elevation, and shape conventions.
- Do not mix M2 and M3 components. If an M3 equivalent exists, use it.

See `THEMING.md` for color, typography, and spacing governance.

---

## Widget composition over inheritance

### Rule

Build complex widgets by **composing** smaller widgets, not by extending them.

```dart
// GOOD: composition
class LaunchCard extends StatelessWidget {
  const LaunchCard({super.key, required this.launch});
  final LaunchPoint launch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          LaunchHeader(name: launch.name),
          LaunchConditionsSummary(launch: launch),
          LaunchActions(launch: launch),
        ],
      ),
    );
  }
}

// BAD: inheritance
class LaunchCard extends Card {
  // Don't extend framework widgets to add behavior
}
```

### Why

- Composition is flexible — swap out parts without rewriting the whole widget.
- Inheritance couples you to the parent's implementation details.
- Flutter's widget tree is designed for composition; fighting it creates brittle code.

---

## Stateless vs. StatefulWidget decision criteria

### Use `StatelessWidget` (or `ConsumerWidget`) when:

- The widget has no local mutable state
- All data comes from constructor parameters or Riverpod providers
- There are no animation controllers, text controllers, or focus nodes

### Use `StatefulWidget` (or `ConsumerStatefulWidget`) when:

- The widget owns an `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode`, or `TabController`
- The widget has ephemeral local state that does not need to be shared (e.g., "is this dropdown expanded?")
- The widget needs `initState` or `dispose` lifecycle methods

### Decision test

> "Does this widget allocate a resource that must be disposed?"
>
> **Yes** → `StatefulWidget` / `ConsumerStatefulWidget`
> **No** → `StatelessWidget` / `ConsumerWidget`

---

## ConsumerWidget usage

### Rule

For any widget that reads Riverpod providers, use `ConsumerWidget` (not `StatelessWidget` + `Consumer` wrapper and not `StatefulWidget` + `ConsumerStatefulWidget` unless lifecycle methods are needed).

```dart
// GOOD
class ConditionsDisplay extends ConsumerWidget {
  const ConditionsDisplay({super.key, required this.launch});
  final LaunchPoint launch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = ref.watch(conditionsProvider(launch));
    return conditions.when(
      loading: () => const ConditionsLoadingSkeleton(),
      error: (e, _) => ConditionsErrorCard(error: e),
      data: (data) => ConditionsContent(data: data),
    );
  }
}

// BAD: unnecessary Consumer wrapper
class ConditionsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // ...
      },
    );
  }
}
```

### When `Consumer` wrapper is appropriate

Use the `Consumer` widget (not `ConsumerWidget`) to **narrow rebuild scope** within a larger widget that doesn't need to rebuild entirely:

```dart
class BigScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StaticHeader(), // never rebuilds
        Consumer(
          builder: (context, ref, _) {
            final count = ref.watch(counterProvider);
            return Text('$count'); // only this rebuilds
          },
        ),
      ],
    );
  }
}
```

---

## Responsive and adaptive layout expectations

- Support portrait and landscape orientations unless a screen is explicitly portrait-locked.
- Use `LayoutBuilder` or `MediaQuery` for responsive breakpoints. See `RESPONSIVENESS.md`.
- Test on multiple screen sizes (phone, tablet) and orientations.
- Text must be readable at all supported text scale factors.

---

## Accessibility requirements in every widget

Every widget that displays content or accepts interaction must meet these minimums:

1. **Semantic labels:** Interactive elements (buttons, icons, images) have `semanticLabel` or are wrapped in `Semantics`.
2. **Touch targets:** Minimum 48x48 logical pixels for tappable areas.
3. **Contrast:** Text meets WCAG 2.1 AA contrast ratios (4.5:1 normal text, 3:1 large text).
4. **Screen reader order:** Logical reading order matches visual order.
5. **Dynamic text:** Widget layouts accommodate text scale factors up to 2.0x without overflow or clipping.
6. **No color-only information:** Color is supplemented with text, icons, or patterns.

See `RESPONSIVENESS.md` for adaptive sizing details.

---

## Loading, error, and empty state requirements

### Every data-driven widget must handle three states

| State | Requirement |
|-------|-------------|
| **Loading** | Show a skeleton, shimmer, or progress indicator. Never a blank screen. |
| **Error** | Show a user-friendly message with optional retry. Never a raw exception. Never a blank screen. |
| **Empty** | Show an intentional empty state with guidance. "No launches found. Try adjusting your filters." Never a blank list. |

### Patterns

```dart
// AsyncValue pattern
asyncValue.when(
  loading: () => const LoadingSkeleton(),
  error: (e, _) => ErrorCard(
    message: 'Could not load conditions',
    onRetry: () => ref.invalidate(conditionsProvider(launch)),
  ),
  data: (items) => items.isEmpty
    ? const EmptyState(message: 'No conditions available')
    : ConditionsList(items: items),
);
```

### Rules

1. Loading states appear within 100ms of navigation (no perceptible blank frame).
2. Error messages are human-readable, not technical. "Network error" not "SocketException: OS Error: Connection refused."
3. Retry actions are always available on error states.
4. Empty states explain **why** it's empty and **what to do** if applicable.

---

## Widget size limits

### Guidance

- **Target: < 150 lines per widget file.** This is a guideline, not a hard rule.
- **Hard limit: 300 lines.** If a widget file exceeds 300 lines, extract sub-widgets.
- **`build()` methods:** target < 50 lines. If `build()` is long, the widget is doing too much — extract child widgets or helper methods.

### Extraction strategy

1. Identify logical sections in the widget (header, body, actions, etc.).
2. Create `const`-constructable child widgets for each section.
3. Pass data down via constructor parameters.
4. If a child needs provider access, make it a `ConsumerWidget`.

### File organization

One public widget per file. Private helper widgets in the same file are acceptable if they are small (< 30 lines) and tightly coupled to the public widget.
