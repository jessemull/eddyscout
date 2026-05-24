# Platform-Specific Development

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when implementing features that behave differently across platforms (Android, iOS, Web).

## References

- `docs/PLATFORMS.md` — platform rules, permissions, conditional capabilities

## Platform Targets

| Platform | Priority | Notes |
|----------|----------|-------|
| Android | Primary | Target API 21+ (minSdk) |
| iOS | Primary | Target iOS 14+ |
| Web | Secondary | Progressive enhancement |

## Checklist

### 1. Check Platform Rules

- [ ] Read `docs/PLATFORMS.md` for platform-specific constraints
- [ ] Identify which platforms the feature must support
- [ ] Determine if native platform APIs are needed

### 2. Use Conditional Imports (if needed)

- [ ] Create platform-specific implementations:
  ```
  src/
  ├── feature_stub.dart      # fallback / stub
  ├── feature_mobile.dart     # Android + iOS
  └── feature_web.dart        # Web
  ```
- [ ] Use conditional imports:
  ```dart
  import 'feature_stub.dart'
    if (dart.library.io) 'feature_mobile.dart'
    if (dart.library.html) 'feature_web.dart';
  ```

### 3. Abstract Behind an Interface

- [ ] Define a platform-agnostic interface in `domain/`
- [ ] Implement platform-specific versions in `data/`
- [ ] Register the correct implementation via Riverpod provider overrides
- [ ] Consumers depend only on the interface

### 4. Handle Permissions

- [ ] Declare permissions in `AndroidManifest.xml` and `Info.plist`
- [ ] Request permissions at runtime with user explanation
- [ ] Handle denial gracefully — show fallback UI
- [ ] Permission changes require human review

### 5. Test on Target Platforms

- [ ] Run on physical devices or platform-specific emulators
- [ ] Test permission flows (grant, deny, revoke)
- [ ] Verify platform-specific UI conventions (Material vs. Cupertino cues)

### 6. Document

- [ ] Document platform-specific behavior in the feature's README or doc comments
- [ ] Note any platform limitations or workarounds
- [ ] Run `make preflight`
