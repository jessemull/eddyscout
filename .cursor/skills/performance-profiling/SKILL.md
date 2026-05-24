# Performance Profiling

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when investigating UI jank, slow frames, excessive rebuilds, or memory issues.

## References

- `docs/PERFORMANCE.md` — performance budgets, optimization patterns

## Checklist

### 1. Enable Performance Overlay

- [ ] Run the app in profile mode: `flutter run --profile`
- [ ] Enable the performance overlay (`showPerformanceOverlay: true`)
- [ ] Identify frames exceeding the 16ms budget

### 2. Use DevTools Timeline

- [ ] Open Flutter DevTools → Performance tab
- [ ] Record a trace while reproducing the slow interaction
- [ ] Identify long build, layout, or paint phases
- [ ] Check for unnecessary widget rebuilds in the flame chart

### 3. Identify Expensive Rebuilds

- [ ] Look for widgets rebuilding on every frame
- [ ] Check for `Consumer` / `ref.watch` at too high a level in the tree
- [ ] Use `ref.select` to narrow provider subscriptions
- [ ] Verify `const` constructors on stateless subtrees

### 4. Check Memory

- [ ] Open DevTools → Memory tab
- [ ] Look for retained objects that should have been garbage collected
- [ ] Verify `autoDispose` on providers holding large data
- [ ] Check for listener leaks (streams, controllers not cancelled)

### 5. Optimize

- [ ] Add `const` to widgets and constructors where possible
- [ ] Use `ref.select` instead of `ref.watch` for fine-grained updates
- [ ] Replace `ListView` with `ListView.builder` for long lists
- [ ] Use `SliverList` / `SliverGrid` in `CustomScrollView`
- [ ] Cache expensive computations with `Provider` or `select`
- [ ] Avoid `Opacity` widget — prefer `AnimatedOpacity` or `FadeTransition`

### 6. Verify Improvement

- [ ] Re-run the profile mode trace
- [ ] Confirm frames are within the 16ms budget
- [ ] Compare before/after metrics
- [ ] Run `make preflight`
