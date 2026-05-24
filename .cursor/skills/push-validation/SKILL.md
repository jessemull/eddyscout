# Push Validation

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use before pushing commits to the remote to ensure all quality gates pass.

## References

- `docs/GOVERNANCE.md` — push and CI policies
- `docs/TESTING.md` — coverage thresholds

## Checklist

### 1. Run Full Quality Gates

```bash
make preflight
```

- [ ] Formatting passes (`dart format --set-exit-if-changed .`)
- [ ] Static analysis passes (`dart analyze --fatal-infos`)
- [ ] All tests pass (`flutter test`)
- [ ] Codegen is fresh (`make gen-check`)

### 2. Verify Code Generation

- [ ] Run `make gen-check` (or `scripts/codegen_verify.sh`)
- [ ] If stale, run `make gen` and commit the regenerated files
- [ ] Never hand-edit `*.g.dart`, `*.freezed.dart`, `*.gr.dart`

### 3. Run Tests on Affected Packages

- [ ] Use `melos run test --since=origin/main` to test only changed packages
- [ ] For broad changes, run the full suite: `make test`
- [ ] Verify no flaky or non-deterministic tests

### 4. Check Coverage Thresholds

- [ ] Run tests with coverage: `flutter test --coverage`
- [ ] Verify coverage meets the minimum threshold from `docs/TESTING.md`
- [ ] Add missing tests if coverage drops below threshold

### 5. Push

- [ ] Push to the feature branch: `git push -u origin HEAD`
- [ ] Verify CI checks pass in the GitHub Actions dashboard
- [ ] Address any CI failures before requesting review
