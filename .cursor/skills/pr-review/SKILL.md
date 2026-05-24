# PR Review

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when reviewing a pull request for code quality, architecture compliance, and standards.

## References

- `docs/REVIEW.md` — review checklist and approval criteria
- `docs/ARCHITECTURE.md` — layer boundaries
- `docs/TESTING.md` — coverage thresholds
- `docs/SECURITY.md` — security review items

## Checklist

### 1. Architecture Compliance

- [ ] Feature follows `presentation/ → domain/ → data/` separation
- [ ] No cross-feature imports
- [ ] Packages do not import from `apps/`
- [ ] `domain/` has no dependencies on `data/` or `presentation/`

### 2. Riverpod Patterns

- [ ] Correct provider type chosen (see Riverpod Usage skill)
- [ ] `autoDispose` used by default
- [ ] `AsyncValue` fully handled (loading, error, data)
- [ ] No business logic in widgets

### 3. Widget Design

- [ ] `const` constructors used where possible
- [ ] No async work in `build()`
- [ ] Widget tree is not deeply nested — extract sub-widgets
- [ ] Material 3 tokens used (no hardcoded colors/text styles)

### 4. Performance

- [ ] No unnecessary rebuilds (check `ref.watch` scope)
- [ ] Long lists use `ListView.builder` or slivers
- [ ] Images are cached and sized appropriately

### 5. Accessibility

- [ ] `Semantics` labels on interactive elements
- [ ] Touch targets ≥ 48×48 dp
- [ ] Text scales correctly at 2× font size

### 6. Security

- [ ] No hardcoded secrets or API keys
- [ ] PII not logged
- [ ] Network calls use HTTPS

### 7. Tests

- [ ] Unit tests for domain and data logic
- [ ] Widget tests for screens
- [ ] Tests are deterministic (no real timers, no real network)
- [ ] Coverage meets thresholds from `docs/TESTING.md`

### 8. Provide Feedback

Categorize findings:
- **MUST** — blocking issues (architecture violations, bugs, security)
- **SHOULD** — important improvements (performance, accessibility)
- **NICE-TO-HAVE** — style suggestions, minor optimizations
