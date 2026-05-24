# Golden Testing

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when adding or updating visual regression tests (golden image comparisons).

## References

- `docs/TESTING.md` — testing strategy, golden test conventions

## Checklist

### 1. Create Golden Test File

- [ ] Name the file `<widget>_golden_test.dart`
- [ ] Place in `test/` mirroring the source path
- [ ] Import `golden_toolkit` and the widget under test

### 2. Set Up Device Scenarios

```dart
testGoldens('MyWidget renders correctly', (tester) async {
  final builder = DeviceBuilder()
    ..overrideDevicesForAllScenarios(devices: [
      Device.phone,
      Device.tabletPortrait,
      Device.tabletLandscape,
    ])
    ..addScenario(
      widget: const MyWidget(),
      name: 'default state',
    )
    ..addScenario(
      widget: const MyWidget(isLoading: true),
      name: 'loading state',
    );

  await tester.pumpDeviceBuilder(builder);
  await screenMatchesGolden(tester, 'my_widget');
});
```

- [ ] Include phone, tablet portrait, and tablet landscape devices
- [ ] Add scenarios for key states: default, loading, error, empty

### 3. Wrap with Required Ancestors

- [ ] Wrap the widget in `MaterialApp` with the app theme
- [ ] Wrap in `ProviderScope` with necessary overrides
- [ ] Provide `MediaQuery` data if testing specific sizes

### 4. Generate Golden Files

```bash
flutter test --update-goldens
```

- [ ] Run `flutter test --update-goldens` to create baseline images
- [ ] Review generated images in the `goldens/` directory
- [ ] Verify images look correct before committing

### 5. Commit Golden Images

- [ ] Commit golden images alongside the test file
- [ ] Golden images are tracked in git (not gitignored)
- [ ] Use a consistent naming convention: `<widget>_<scenario>.png`

### 6. CI Verification

- [ ] Golden tests run in CI via `flutter test` (no `--update-goldens` flag)
- [ ] CI fails if pixel differences exceed the tolerance threshold
- [ ] Update goldens intentionally — never to fix a "flaky" test without investigation

### 7. Validate

- [ ] Run `make preflight`
- [ ] Verify no unintended golden file changes in `git diff`
