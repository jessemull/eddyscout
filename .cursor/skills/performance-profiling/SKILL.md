---
name: performance-profiling
description: >-
  Profile and optimize EddyScout performance: rebuild isolation, frame
  budgets, memory safety, and provider efficiency. Use when investigating
  jank, excessive rebuilds, or memory regressions.
---

# Performance Profiling

Read the following before investigating or optimizing performance issues:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/PERFORMANCE.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/UI.md`
- `docs/TESTING.md`

Companion skills:
- `riverpod-usage` — provider rebuild isolation and `ref.select()` patterns
- `debugging` — systematic investigation when performance root cause is unclear
- `testing` — verify performance fixes don't regress behavior

Performance is a **first-class architectural constraint**, not an afterthought.

This includes:
- frame rendering performance
- rebuild frequency
- memory usage
- jank detection
- startup time
- scroll performance
- animation smoothness

---

# When to Use

Use this skill when:

- UI feels slow or janky
- scrolling is not smooth
- animations stutter
- app startup is slow
- memory usage grows unexpectedly
- widgets rebuild excessively
- DevTools shows frame drops
- battery usage is high
- CPU usage spikes

---

# Core Performance Principles

## Performance Is Measured, Not Assumed

All optimization must be based on:
- DevTools profiling
- frame timing data
- rebuild analysis
- memory snapshots

Avoid:
- guess-based optimizations
- premature micro-optimizations
- blind refactoring

---

## Rebuild Control Is the Primary Lever

Most Flutter performance issues come from:
- excessive rebuilds
- poorly scoped providers
- missing const widgets
- overly broad widget trees

---

## UI Should Be Predictable

Rendering must be:
- deterministic
- cacheable where possible
- minimally reactive
- scoped to smallest necessary subtree

---

# 1. Performance Reproduction

## Environment Setup

- [ ] run in profile mode

```bash id="perf1"
flutter run --profile
```

- [ ] reproduce issue under realistic conditions
- [ ] avoid debug-mode artifacts

---

## Identify Trigger Path

- [ ] identify exact user interaction causing issue
- [ ] record before/after behavior
- [ ] confirm reproducibility
- [ ] determine if issue is deterministic

---

# 2. Frame Analysis (16ms Budget)

## Performance Overlay

- [ ] enable performance overlay
- [ ] identify frames exceeding budget
- [ ] distinguish UI vs raster thread issues

Key signals:
- UI thread spike → rebuild/layout issue
- Raster thread spike → painting/overdraw issue

---

## DevTools Timeline

- [ ] record performance trace
- [ ] analyze build → layout → paint pipeline
- [ ] identify long-running tasks
- [ ] locate widget causing cascade rebuild

---

# 3. Rebuild Analysis

## Provider Scope Review

- [ ] ensure `ref.watch` is not overly broad
- [ ] isolate provider subscriptions
- [ ] use `ref.select` for granular updates

## Widget Tree Optimization

- [ ] remove unnecessary parent rebuild triggers
- [ ] split large widgets into smaller components
- [ ] ensure subtree isolation of dynamic areas

## Const Optimization

- [ ] add `const` constructors where possible
- [ ] ensure immutable widget subtrees
- [ ] verify static widgets are not rebuilt

---

# 4. Scroll & List Performance

## List Optimization

- [ ] use `ListView.builder` for large lists
- [ ] avoid `Column` with unbounded children
- [ ] use `SliverList` / `SliverGrid` for complex layouts
- [ ] enable lazy rendering where applicable

## Image Performance

- [ ] ensure images are sized appropriately
- [ ] use caching for remote images (`CachedNetworkImage` or equivalent when UI loads network images)
- [ ] avoid decoding large images on main thread
- [ ] avoid repeated image rebuilds

---

# 5. Rendering Optimization

## Paint Efficiency

- [ ] avoid excessive `Opacity` usage
- [ ] prefer `AnimatedOpacity` or `FadeTransition`
- [ ] minimize repaint boundaries
- [ ] reduce overdraw

## Layout Efficiency

- [ ] avoid deeply nested layout trees
- [ ] eliminate redundant `SizedBox` / constraints
- [ ] prefer flexible layouts over fixed dimensions

---

# 6. Memory Profiling

## DevTools Memory Analysis

- [ ] inspect memory growth over time
- [ ] identify retained objects
- [ ] check for leaks in controllers and streams

## Lifecycle Safety

- [ ] dispose of:
  - controllers
  - streams
  - animations
  - listeners

## Riverpod Memory Safety

- [ ] use `autoDispose` where appropriate
- [ ] avoid long-lived unnecessary providers
- [ ] ensure providers do not retain large graphs

---

# 7. Async Performance

## Async Behavior

- [ ] avoid blocking UI thread
- [ ] ensure heavy computation is offloaded
- [ ] debounce rapid state updates
- [ ] batch updates where possible

---

# 8. Animation Performance

## Rules

- [ ] prefer GPU-accelerated animations
- [ ] avoid layout-triggering animations where possible
- [ ] keep animation trees shallow
- [ ] avoid rebuilding entire subtrees during animation

---

# 9. Network & Data Performance

- [ ] avoid repeated API calls on rebuild
- [ ] cache expensive network responses
- [ ] debounce search queries
- [ ] paginate large datasets

---

# 10. Optimization Techniques

## State Optimization

- [ ] use `ref.select` for granular updates
- [ ] split providers by responsibility
- [ ] avoid global state subscriptions

## Widget Optimization

- [ ] break large widgets into subwidgets
- [ ] isolate dynamic regions
- [ ] reduce build method complexity

## Computation Optimization

- [ ] cache expensive calculations
- [ ] move computation to providers
- [ ] avoid recomputation in build

---

# 11. Verification

## Before/After Comparison

- [ ] re-run profile trace
- [ ] confirm frame improvement
- [ ] confirm no regressions introduced

## Metrics to Validate

- frame time < 16ms target
- reduced rebuild frequency
- reduced memory usage
- improved scroll smoothness

---

# 12. Testing Performance

- [ ] verify no performance regressions in widget tests
- [ ] ensure golden tests still pass
- [ ] ensure integration flows remain smooth

---

# 13. Common Anti-Patterns

## MUST NOT

- [ ] optimize without profiling data
- [ ] overuse `ref.watch` at root levels
- [ ] rebuild entire screens unnecessarily
- [ ] ignore dispose lifecycle
- [ ] perform heavy work in build methods
- [ ] ignore scroll performance

## SHOULD AVOID

- [ ] premature caching
- [ ] excessive abstraction for performance
- [ ] micro-optimizations without evidence

---

# 14. Validation Checklist

Before committing:

- [ ] performance issue reproduced and measured
- [ ] root cause identified in DevTools
- [ ] optimization applied with rationale
- [ ] before/after comparison documented
- [ ] tests pass
- [ ] preflight passes

Run:

```bash id="perf2"
make preflight
```

---

# 15. Output Expectations

When performing performance profiling, provide:

## Issue Summary
- observed slowdown
- reproduction steps
- affected screens/components

## Root Cause Analysis
- rebuild cause
- rendering cause
- memory cause

## Fix Summary
- changes applied
- optimization strategy used

## Metrics
- frame time improvement
- rebuild reduction
- memory impact

## Risk Assessment
- potential regressions
- tradeoffs introduced
