# Dependency Upgrade

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when adding, upgrading, or removing a dependency in any `pubspec.yaml`.

## References

- `docs/DEPENDENCIES.md` — approved packages, evaluation criteria, audit schedule

## Evaluation Criteria

Before adding or upgrading a dependency, evaluate:

| Criterion | Requirement |
|-----------|-------------|
| Maintenance | Active commits within last 6 months |
| Popularity | Prefer packages with high pub.dev likes/points |
| License | Must be compatible (MIT, BSD, Apache 2.0) |
| Size | Prefer lightweight; avoid bloated transitive trees |
| Null safety | Must support Dart 3+ null safety |
| Platform | Must support required platforms (Android, iOS, Web) |

## Checklist

### 1. Check the Approved List

- [ ] Read `docs/DEPENDENCIES.md` for the current approved dependency list
- [ ] If the package is already approved, proceed with the upgrade
- [ ] If not approved, evaluate using the criteria above and flag for human review

### 2. Evaluate the Package

- [ ] Check pub.dev for maintenance status, popularity, and license
- [ ] Review the changelog for breaking changes
- [ ] Check transitive dependencies for conflicts
- [ ] Verify platform support matches project needs

### 3. Update `pubspec.yaml`

- [ ] Pin to a version range: `^x.y.z` (caret syntax)
- [ ] Update in the correct `pubspec.yaml` (app or package)
- [ ] For monorepo-wide deps, consider adding to `tooling/` or root

### 4. Resolve Dependencies

```bash
dart pub get
```

- [ ] Run `dart pub get` in the affected package
- [ ] Resolve any version conflicts
- [ ] Check for deprecated API usage in the upgrade

### 5. Run Full Test Suite

- [ ] Run `make test` to verify no regressions
- [ ] Run `make analyze` to check for new warnings
- [ ] Run `make preflight` for all quality gates

### 6. Update Documentation

- [ ] Add new dependencies to `docs/DEPENDENCIES.md`
- [ ] Note the justification and approved version range
- [ ] New dependencies require human review (see `CONTEXT.md` escalation rules)
