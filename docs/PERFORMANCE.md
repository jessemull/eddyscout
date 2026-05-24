# Performance

> **Precedence**: CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this document
>
> **AI agents**: Read this if your task involves widget rendering, list views, animations, images, state management optimization, or profiling.

## Frame Budget

- **60fps target**: 16.67ms per frame
- **120fps target**: 8.33ms per frame
- build() must complete well under the frame budget
- Profile in **release mode** — debug mode is not representative

## Rebuild Minimization

### const Constructors

Use `const` constructors everywhere possible. The analyzer enforces `prefer_const_constructors` as an error.

```dart
// Good
const SizedBox(height: 16)
const Text('Hello')

// Bad — unnecessary rebuild
SizedBox(height: 16)
Text('Hello')
```

### ConsumerWidget Granularity

Use the most specific `ref.watch` and `select()` to minimize rebuild scope:

```dart
// Good — only rebuilds when name changes
final name = ref.watch(userProvider.select((u) => u.name));

// Bad — rebuilds on ANY user property change
final user = ref.watch(userProvider);
```

### Widget Extraction

Extract sub-widgets to create independent rebuild boundaries:

```dart
// Good — each section rebuilds independently
Column(
  children: const [
    _Header(),
    _Body(),
    _Footer(),
  ],
)
```

## Lists and Scrolling

### Sliver Usage

Use `SliverList` / `SliverGrid` for lists with more than ~20 items. Never use `ListView` without `itemCount`.

```dart
// Good — virtualized
SliverList.builder(
  delegate: SliverChildBuilderDelegate(
    (context, index) => LaunchPointTile(points[index]),
    childCount: points.length,
  ),
)

// Bad — builds all children at once
ListView(
  children: points.map((p) => LaunchPointTile(p)).toList(),
)
```

### itemExtent

When list items have known fixed height, always provide `itemExtent` for O(1) scroll calculations.

### Nested ScrollViews

Never nest `ScrollView` widgets without explicit constraints:
- Inner scroll must use `NeverScrollableScrollPhysics`
- Inner list must use `shrinkWrap: true` (and be bounded)
- Prefer `CustomScrollView` with mixed slivers instead

## Image Optimization

- Use appropriately sized images (don't load 4K for a 100px thumbnail)
- Cache network images (use `CachedNetworkImage` or equivalent)
- Prefer WebP format for smaller file sizes
- Use `Image.asset` with resolution-aware variants (2x, 3x)
- Dispose image caches when memory pressure is high

## Animations

- Prefer implicit animations (`AnimatedContainer`, `AnimatedOpacity`) for simple transitions
- Use explicit animations (`AnimationController`) only when implicit animations are insufficient
- Always dispose `AnimationController` in `dispose()`
- Keep animations under 300ms for UI responsiveness
- Use `Curves.easeInOut` as default curve

## Memory Management

### Controller Disposal

Every controller must be disposed in `dispose()`:
- `TextEditingController`
- `ScrollController`
- `AnimationController`
- `FocusNode`
- `TabController`

### Stream Disposal

Cancel all stream subscriptions in `dispose()`:

```dart
late final StreamSubscription _subscription;

@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```

With Riverpod, prefer `ref.listen()` which auto-cancels.

### Provider Lifecycle

- Use `autoDispose` for providers that should be cleaned up when no longer watched
- Use `keepAlive` only for expensive cached data
- Call `ref.invalidate()` to force re-fetch

## Forbidden Patterns

The following are explicitly banned in `build()` and will be caught by analysis/review:

| Pattern | Why | Alternative |
|---------|-----|-------------|
| Network calls in build() | Triggers on every rebuild | Use FutureProvider / AsyncNotifier |
| File I/O in build() | Blocking, causes jank | Load in provider, watch result |
| Heavy computation in build() | Exceeds frame budget | Compute in isolate, cache in provider |
| setState cascades | Causes multiple rebuilds per frame | Batch state updates |
| Creating providers in build() | Memory leaks, lost state | Define providers at top level |
| Unbounded ListView | Builds all children, OOM risk | Use ListView.builder with itemCount |
| Synchronous JSON parsing of large payloads | Jank on main isolate | Use compute() or Isolate.run() |

## DevTools Profiling

### When to Profile

- Before merging any PR that touches widget rendering
- When users report jank or slow screens
- After adding new list/grid views
- After adding animations

### How to Profile

1. Run in **release mode** (`flutter run --release`)
2. Open DevTools Performance tab
3. Record a trace of the target interaction
4. Check for frames exceeding 16ms
5. Identify expensive build/layout/paint phases
6. Look for unnecessary rebuilds in the widget tree

### Performance Regression Detection

- Golden tests catch visual regressions
- Frame budget violations should be caught in integration tests with `FrameTimingSummarizer`
- Manual profiling required before merging rendering changes
