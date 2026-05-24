# Debugging

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when investigating bugs, unexpected behavior, or runtime errors.

## References

- `docs/TESTING.md` — writing regression tests
- `docs/ARCHITECTURE.md` — layer boundaries for isolating issues

## Checklist

### 1. Reproduce the Issue

- [ ] Identify exact steps to trigger the bug
- [ ] Note the expected vs. actual behavior
- [ ] Check if the issue is deterministic or intermittent
- [ ] Record the platform, device, and Flutter/Dart version

### 2. Inspect with DevTools

- [ ] **Widget Inspector** — verify widget tree structure and properties
- [ ] **Performance Overlay** — check for janky frames (>16ms)
- [ ] **Network Tab** — inspect HTTP requests/responses for API issues
- [ ] **Logging Tab** — review console output and error stack traces

### 3. Add Breakpoints

- [ ] Set breakpoints in the suspected code path
- [ ] Use conditional breakpoints for intermittent issues
- [ ] Step through execution and inspect variable state
- [ ] Use `.vscode/launch.json` debug configs if available

### 4. Check Riverpod Provider State

- [ ] Use Riverpod DevTools or `ProviderObserver` to trace state changes
- [ ] Verify providers are not disposed prematurely
- [ ] Check for circular dependencies or missing overrides
- [ ] Confirm `AsyncValue` states are handled (loading/error/data)

### 5. Isolate in a Test

- [ ] Write a minimal failing test that reproduces the bug
- [ ] Use `ProviderContainer` with overrides to isolate provider logic
- [ ] Mock external dependencies (network, storage) with `mocktail`

### 6. Fix and Verify

- [ ] Apply the fix in the correct layer (domain/data/presentation)
- [ ] Confirm the failing test now passes
- [ ] Run `make preflight` to verify no regressions
- [ ] Commit with `fix(<scope>): <description>`
