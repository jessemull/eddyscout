---
name: debugging
description: >-
  Systematic debugging for EddyScout: reproduce, isolate, fix. Use when
  investigating crashes, state bugs, rendering issues, async problems,
  navigation bugs, performance regressions, or flaky tests.
---

# Debugging

Read the following before performing debugging work:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/ARCHITECTURE.md`
- `docs/TESTING.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/PERFORMANCE.md`
- `docs/NETWORKING.md`
- `docs/SECURITY.md`

Conditional reads:
- `docs/ERROR_HANDLING.md` — when debugging error/failure flows
- `docs/NAVIGATION.md` — when debugging navigation or route issues

Companion skills:
- `riverpod-usage` — provider lifecycle and state debugging
- `performance-profiling` — frame budget and rebuild analysis

Debugging is an engineering discipline.

Do not:
- guess
- patch blindly
- suppress symptoms
- add speculative fixes
- introduce workaround hacks

All debugging work must:
- identify root cause
- isolate failure conditions
- verify reproducibility
- preserve architecture integrity
- avoid regressions
- produce deterministic fixes

---

# When to Use

Use this skill when investigating:

- crashes
- runtime exceptions
- rendering bugs
- state inconsistencies
- rebuild issues
- async issues
- provider lifecycle issues
- navigation bugs
- performance problems
- memory leaks
- animation jank
- networking failures
- serialization failures
- flaky tests
- CI failures
- platform-specific bugs
- accessibility issues
- code generation issues

---

# Core Debugging Principles

## Reproduce First

Never attempt fixes before reproducing the issue reliably.

Understand:
- exact trigger conditions
- affected environments
- failure frequency
- platform/device scope
- timing dependencies

---

## Minimize Variables

Reduce the problem to:
- smallest failing state
- smallest failing widget
- smallest failing provider
- smallest failing async flow

Simplify aggressively.

---

## Fix Root Cause, Not Symptoms

Avoid:
- arbitrary delays
- unnecessary retries
- forced rebuilds
- defensive null checks hiding real bugs
- lifecycle hacks
- state-reset workarounds

Identify:
- architectural cause
- lifecycle issue
- invalid assumptions
- async ordering problem
- rebuild trigger source

---

## Preserve Architecture Integrity

Do not violate:
- layer boundaries
- state ownership
- dependency direction
- provider responsibilities

to quickly patch a bug.

---

# 1. Issue Intake & Classification

## Capture Initial Context

Document:

- [ ] expected behavior
- [ ] actual behavior
- [ ] reproduction steps
- [ ] affected platforms
- [ ] affected devices
- [ ] Flutter version
- [ ] Dart version
- [ ] package versions involved
- [ ] environment/build mode
- [ ] frequency of occurrence

## Classify Issue Type

- [ ] crash
- [ ] rendering/UI bug
- [ ] state inconsistency
- [ ] async timing issue
- [ ] navigation issue
- [ ] networking issue
- [ ] performance issue
- [ ] memory leak
- [ ] accessibility issue
- [ ] platform-specific issue
- [ ] test flake
- [ ] CI/build issue
- [ ] code generation issue

---

# 2. Reproduction Verification

## Determinism

- [ ] Issue reproduced locally
- [ ] Reproduction reliable
- [ ] Reproduction steps minimized
- [ ] Failure conditions isolated

## Scope Isolation

Determine whether issue is:
- [ ] global
- [ ] feature-specific
- [ ] provider-specific
- [ ] widget-specific
- [ ] platform-specific
- [ ] environment-specific
- [ ] timing-sensitive

---

# 3. Debugging Environment Setup

## Build Mode Validation

Verify issue behavior in:
- [ ] debug
- [ ] profile
- [ ] release

Some issues only appear in:
- release optimizations
- async timing
- production networking
- platform integration

---

# 4. Flutter DevTools Investigation

## Widget Inspector

- [ ] Verify widget hierarchy
- [ ] Verify inherited widget scope
- [ ] Verify provider scope
- [ ] Check rebuild frequency
- [ ] Inspect layout constraints
- [ ] Inspect semantic tree

## Performance Tools

- [ ] Check frame timing
- [ ] Identify janky frames
- [ ] Inspect shader compilation issues
- [ ] Inspect rebuild spikes
- [ ] Inspect layout thrashing
- [ ] Inspect raster thread issues

## Memory Tools

- [ ] Inspect memory growth
- [ ] Check retained objects
- [ ] Check controller disposal
- [ ] Check stream disposal
- [ ] Check image cache behavior
- [ ] Identify leaks

## Network Tools

- [ ] Inspect HTTP requests
- [ ] Verify retries
- [ ] Verify headers
- [ ] Verify auth state
- [ ] Verify caching behavior
- [ ] Verify serialization

## Logging & Timeline

- [ ] Review stack traces
- [ ] Review async ordering
- [ ] Inspect event timeline
- [ ] Identify race conditions
- [ ] Verify navigation ordering

---

# 5. Breakpoint & Runtime Inspection

## Breakpoint Strategy

- [ ] Set breakpoints near failure point
- [ ] Use conditional breakpoints where appropriate
- [ ] Verify state transitions
- [ ] Verify async ordering
- [ ] Inspect provider lifecycle

## Variable Inspection

- [ ] Verify nullability assumptions
- [ ] Verify async state correctness
- [ ] Verify lifecycle state
- [ ] Verify mounted/disposed state
- [ ] Verify serialization values

---

# 6. Riverpod / State Management Debugging

## Provider Lifecycle

- [ ] Verify provider initialization
- [ ] Verify disposal timing
- [ ] Verify invalidation behavior
- [ ] Verify override configuration
- [ ] Verify provider ownership

## AsyncValue Handling

- [ ] Loading states handled
- [ ] Error states handled
- [ ] Empty states handled
- [ ] Stale state avoided
- [ ] Duplicate requests avoided

## Rebuild Analysis

- [ ] Identify rebuild triggers
- [ ] Verify `ref.watch` scope
- [ ] Verify selectors used appropriately
- [ ] Minimize rebuild propagation

## Dependency Graph

- [ ] No circular provider dependencies
- [ ] No hidden state coupling
- [ ] No duplicated provider responsibilities

---

# 7. Async & Lifecycle Debugging

## Async Safety

- [ ] Check race conditions
- [ ] Check duplicate requests
- [ ] Check stale async updates
- [ ] Check cancellation handling
- [ ] Check timeout handling

## Lifecycle Safety

- [ ] No `BuildContext` after async gaps
- [ ] `mounted` checks correct
- [ ] Controllers disposed correctly
- [ ] Streams disposed correctly
- [ ] Timers cleaned up
- [ ] Subscriptions cancelled

## Navigation Timing

- [ ] Navigation lifecycle safe
- [ ] Dialog timing correct
- [ ] Overlay lifecycle correct
- [ ] Route disposal safe

---

# 8. UI & Rendering Debugging

## Layout Issues

- [ ] Constraint violations identified
- [ ] Overflow conditions reproduced
- [ ] Infinite layout loops avoided
- [ ] Adaptive layouts verified

## Rendering Issues

- [ ] Large widget rebuilds identified
- [ ] Expensive paint operations identified
- [ ] Unnecessary layers avoided
- [ ] Animation performance inspected

## Platform Rendering

- [ ] Android rendering verified
- [ ] iOS rendering verified
- [ ] Web rendering verified
- [ ] Desktop rendering verified

---

# 9. Networking & Serialization Debugging

## API Investigation

- [ ] Requests verified
- [ ] Responses verified
- [ ] Error responses handled
- [ ] Retry behavior verified
- [ ] Auth refresh flow verified

## Serialization

- [ ] JSON structure validated
- [ ] Nullability handled correctly
- [ ] Backward compatibility checked
- [ ] Generated serialization verified

---

# 10. Code Generation Debugging

## Generated Artifacts

- [ ] Regenerate code
- [ ] Remove stale artifacts
- [ ] Verify generated providers
- [ ] Verify generated routes
- [ ] Verify generated models

Run:

```bash
make gen
make gen-check
```

---

# 11. Performance Debugging

## Frame Performance

- [ ] Frame budget respected
- [ ] Rebuild storms identified
- [ ] Expensive sync work isolated
- [ ] Animation jank identified

## Memory Performance

- [ ] Memory leaks identified
- [ ] Excessive allocations identified
- [ ] Image memory usage inspected
- [ ] Provider retention inspected

---

# 12. Platform-Specific Debugging

## Android

- [ ] Lifecycle transitions verified
- [ ] Permissions verified
- [ ] Background behavior verified

## iOS

- [ ] App lifecycle verified
- [ ] Navigation transitions verified
- [ ] Keyboard behavior verified

## Web/Desktop

- [ ] Keyboard navigation verified
- [ ] Resize handling verified
- [ ] Browser compatibility verified

---

# 13. Accessibility Debugging

- [ ] Semantic tree verified
- [ ] Focus traversal verified
- [ ] Screen reader announcements verified
- [ ] Text scaling verified
- [ ] Contrast issues verified

---

# 14. Regression Test Creation

## Reproduction Test

- [ ] Minimal failing test created
- [ ] Failure deterministic
- [ ] Test isolated from external systems
- [ ] Async timing controlled

## Test Types

Use appropriate test type:

- [ ] unit test
- [ ] widget test
- [ ] integration test
- [ ] golden test

---

# 15. Fix Validation

## Root Cause Validation

- [ ] Root cause confirmed
- [ ] Symptom-only fixes avoided
- [ ] Architecture preserved
- [ ] No workaround hacks introduced

## Regression Validation

- [ ] Existing tests pass
- [ ] New regression test passes
- [ ] Related flows verified manually
- [ ] Performance impact reviewed

---

# 16. Final Validation

Run:

```bash
make preflight
```

Verify:

- [ ] analyzer clean
- [ ] formatting clean
- [ ] tests pass
- [ ] codegen clean
- [ ] CI-compatible
- [ ] no new warnings

---

# 17. AI-Assisted Debugging Validation

## AI Safety

- [ ] No speculative fixes
- [ ] No hallucinated APIs/packages
- [ ] Existing repository patterns followed
- [ ] Repository architecture preserved

## Complexity Review

- [ ] Fix complexity justified
- [ ] No unnecessary abstractions added
- [ ] No defensive overengineering introduced

---

# 18. Common Debugging Anti-Patterns

## MUST NOT

- [ ] Patch without reproducing
- [ ] Add arbitrary delays
- [ ] Force rebuilds blindly
- [ ] Suppress exceptions silently
- [ ] Ignore lifecycle violations
- [ ] Introduce architecture violations
- [ ] Ignore async ordering issues

## SHOULD AVOID

- [ ] Excessive logging noise
- [ ] Global state hacks
- [ ] Catch-all exception handling
- [ ] Broad rebuild invalidation
- [ ] Debug-only fixes

---

# 19. Output Expectations

When debugging, provide:

## Issue Summary
- observed behavior
- expected behavior
- affected platforms/features

## Root Cause
- technical cause
- architectural implications
- lifecycle/async implications

## Fix Summary
- what changed
- why it fixes the issue
- regression prevention strategy

## Validation
- tests added
- manual verification performed
- performance implications reviewed