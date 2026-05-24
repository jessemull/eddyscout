## Summary

<!-- What does this PR do? Why? -->

## Type

- [ ] Feature (new functionality)
- [ ] Fix (bug fix)
- [ ] Refactor (code improvement, no behavior change)
- [ ] Test (adding/updating tests)
- [ ] Docs (documentation only)
- [ ] Chore (dependencies, CI, tooling)

## Checklist

### Required
- [ ] `make preflight` passes (format + analyze + test)
- [ ] Codegen is up to date (`make gen-check`)
- [ ] Tests added/updated for changes
- [ ] No new analyzer warnings

### Architecture
- [ ] Changes follow feature-first architecture
- [ ] No cross-feature imports
- [ ] Dependency direction respected (presentation → domain ← data)

### Quality
- [ ] Loading/error/empty states handled
- [ ] Accessibility verified (Semantics, touch targets, text scaling)
- [ ] No hardcoded strings (use localization)
- [ ] No hardcoded colors/styles (use theme)
- [ ] Performance considered (const, select, slivers for lists)

### Security
- [ ] No hardcoded secrets
- [ ] No PII in logs
- [ ] Permissions justified (if changed)

## Review Notes

<!-- Anything reviewers should focus on? -->
