# EddyScout — Platform Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when writing platform-specific code; when configuring Android, iOS, web, or desktop build settings; when using platform channels or conditional imports; or when evaluating platform support for a feature.

---

## Supported Platforms

| Platform | Tier | Status |
|----------|------|--------|
| **Android** | Primary | Active development |
| **iOS** | Primary | Active development |
| **Web** | Secondary | Supported with known limitations |
| **macOS** | Experimental | Best-effort; not release-gated |
| **Linux** | Experimental | Best-effort; not release-gated |
| **Windows** | Experimental | Best-effort; not release-gated |

- **Primary** platforms must pass all CI checks and are release targets.
- **Secondary** platforms must pass analysis and tests; known limitations are documented.
- **Experimental** platforms are not gated in CI and may have incomplete functionality.

## Android-Specific Rules

| Setting | Value |
|---------|-------|
| **Minimum SDK** | API 24 (Android 7.0) |
| **Target SDK** | Latest stable (currently API 35) |
| **Compile SDK** | Latest stable |
| **Kotlin version** | ≥ 1.9 (match Flutter tooling) |
| **Gradle** | Kotlin DSL preferred; version aligned with Flutter's `gradle-wrapper.properties` |
| **NDK** | Only if required by a dependency; pin version in `build.gradle` |

- Use **Jetpack libraries** only when Flutter plugins require them; prefer Flutter-side solutions.
- Declare all permissions in `AndroidManifest.xml` with comments explaining their purpose.
- ProGuard / R8 rules must be tested with release builds before shipping.

## iOS-Specific Rules

| Setting | Value |
|---------|-------|
| **Minimum deployment target** | iOS 16.0 |
| **Swift version** | ≥ 5.9 |
| **Xcode** | Latest stable supported by Flutter stable channel |

- Use CocoaPods as the dependency manager (Flutter default).
- Add required `Info.plist` entries (privacy descriptions) for any permission the app uses.
- Test on both physical devices and simulators — simulators cannot test GPS, camera, or push notifications.

## Web-Specific Rules

- **Renderer:** Use CanvasKit for consistency; fall back to HTML renderer only if bundle size is a hard constraint.
- **SEO:** Flutter web apps are single-page; if SEO matters, consider server-side rendering or a landing page outside Flutter.
- **Limitations:** No access to platform channels, no push notifications, limited file system access. Document any feature that is unavailable on web.
- **Hydration:** Minimize initial load size; use deferred loading for non-critical routes.
- **CORS:** API calls from web must account for CORS; configure backend accordingly.

## Desktop-Specific Rules

- **Window management:** Use `window_manager` or equivalent for custom title bars, minimum window sizes, and multi-window support.
- **Menu bars:** Provide native menu bar integration on macOS; optional on Linux/Windows.
- **File system:** Use `path_provider` for platform-appropriate directories; never hardcode paths.
- **Packaging:** Use platform-native installers (DMG for macOS, MSI/MSIX for Windows, AppImage/Snap for Linux) when distributing.

## Platform Channel Restrictions

When native platform code is unavoidable:

1. **Abstract behind an interface.** Define a Dart interface in the domain layer; implement per-platform behind it.
2. **Use method channels sparingly.** Prefer existing Flutter plugins over custom channels.
3. **Document the contract.** Every method channel must have a documented API contract (method names, argument types, return types, error codes).
4. **Test both sides.** Write Dart-side unit tests with mocked channels and native-side tests (Espresso, XCTest) for the platform implementation.

## Conditional Import Rules

Use Dart conditional imports for platform-divergent implementations:

```dart
import 'stub.dart'
    if (dart.library.io) 'mobile.dart'
    if (dart.library.html) 'web.dart';
```

- Place the stub, mobile, and web files in the same directory.
- The stub must define the same API surface so analysis passes on all platforms.
- Prefer feature detection over platform detection where possible.

## Platform Divergence Policies

Platform-specific code is acceptable when:

| Scenario | Example | Required |
|----------|---------|----------|
| OS-mandated UX patterns | iOS swipe-back, Android back button | Follow platform conventions |
| Hardware capabilities | GPS, camera, biometrics | Guard with capability checks |
| Store requirements | iOS App Tracking Transparency, Android target SDK | Comply per-platform |
| Performance optimization | Platform-specific rendering hints | Document the divergence |

Platform-specific code is **not** acceptable for:

- Business logic (must remain platform-agnostic in the domain layer).
- UI layout differences that are purely aesthetic preference (use adaptive widgets instead).

## Platform Testing Requirements

| Platform | Test type | Frequency |
|----------|-----------|-----------|
| Android | Unit + widget tests | Every PR |
| Android | Integration tests on emulator | Pre-release |
| iOS | Unit + widget tests | Every PR |
| iOS | Integration tests on simulator + device | Pre-release |
| Web | Unit + widget tests | Every PR |
| Web | Browser smoke test (Chrome) | Pre-release |
| Desktop | Unit + widget tests | Best-effort |
