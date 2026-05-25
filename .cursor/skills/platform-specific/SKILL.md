---
name: platform-specific
description: >-
  Implement platform-dependent behavior in EddyScout: permissions,
  conditional APIs, capability detection, and platform-safe abstractions.
  Use when integrating native device capabilities or handling platform
  differences.
---

# Platform-Specific Development

Read the following before implementing any platform-dependent behavior:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/PLATFORMS.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/UI.md`
- `docs/RESPONSIVENESS.md`
- `docs/SECURITY.md`
- `docs/PERFORMANCE.md`
- `docs/TESTING.md`

Companion skills:
- `testing` — widget and integration test conventions for platform-specific code
- `security-review` — permission handling and platform channel security
- `accessibility-review` — platform-adaptive a11y (touch targets, screen readers)

Flutter is inherently cross-platform, but real-world applications still require:
- platform-aware behavior
- permission handling
- conditional APIs
- UI adaptation
- capability detection
- platform-safe abstractions

Poor platform handling leads to:
- runtime crashes
- missing functionality on specific devices
- inconsistent UX
- permission failures
- hard-to-debug platform-specific bugs

---

# When to Use

Use this skill when:

- implementing platform-specific features
- integrating native device capabilities
- handling permissions (camera, location, storage, etc.)
- building web-specific behavior
- handling desktop vs mobile differences
- adapting UI per platform using adaptive constructors
- using conditional imports
- integrating platform channels (if applicable)

---

# Core Platform Principles

## Prefer Capability Over Platform Detection

Avoid hardcoding platform checks like:
- `Platform.isAndroid`
- `kIsWeb` scattered throughout UI

Prefer:
- abstraction layers
- capability services
- injected platform interfaces

---

## Platform Logic Must Be Isolated

Platform-specific logic must NOT leak into:
- widgets
- domain layer
- business logic
- shared providers

It must live in:
- platform adapters
- data layer implementations
- infrastructure services

---

## Always Gracefully Degrade

Every platform feature must have:
- fallback behavior
- disabled state handling
- UI explanation where needed

Never assume a feature is available.

---

# 1. Platform Requirement Analysis

Before implementation:

- [ ] identify required platforms (Android, iOS, Web, Desktop)
- [ ] determine feature parity expectations
- [ ] identify platform-exclusive APIs
- [ ] identify unsupported platform behavior
- [ ] define fallback UX per platform

---

# 2. Platform Rules Review

- [ ] read `docs/PLATFORMS.md`
- [ ] confirm min SDK versions (Android/iOS)
- [ ] confirm web support expectations
- [ ] confirm any restricted APIs per platform
- [ ] confirm permission requirements

---

# 3. Architecture Strategy

## Interface First Design

All platform-dependent logic must be abstracted:

- [ ] define interface in `domain/`
- [ ] implement platform-specific versions in `data/` or `infra/`
- [ ] inject via Riverpod provider

Example pattern:

- `StorageService` (interface)
- `MobileStorageService`
- `WebStorageService`

## Dependency Rule

- domain → no platform imports
- data → platform-specific implementations allowed
- presentation → must remain platform-agnostic where possible

---

# 4. Conditional Implementation Strategy

## When to Use Conditional Imports

Use only when:
- platform differences cannot be abstracted cleanly
- APIs are fundamentally incompatible

## Structure

- [ ] create platform variants:
  - `feature_stub.dart`
  - `feature_mobile.dart`
  - `feature_web.dart`

## Import Rule

```dart
import 'feature_stub.dart'
  if (dart.library.io) 'feature_mobile.dart'
  if (dart.library.html) 'feature_web.dart';
```

## Guidelines

- keep logic minimal per platform file
- avoid duplication across implementations
- ensure identical interface contract

---

# 5. Permissions Handling

## Declaration

- [ ] Android: update `AndroidManifest.xml`
- [ ] iOS: update `Info.plist`
- [ ] Web: ensure API compatibility or fallback

## Runtime Flow

- [ ] request permission at runtime
- [ ] show user-facing rationale before request
- [ ] handle deny / permanently deny cases
- [ ] provide fallback UI or disabled state

## Rules

- never request permission silently
- never assume permission is granted
- always handle denial gracefully

---

# 6. Platform UI Adaptation

## Design System Consistency

- [ ] maintain consistent design language across platforms
- [ ] avoid platform-specific UI unless required
- [ ] use Material 3 as baseline unless explicitly overridden

## When Platform UI Differs

- Use Material 3 as the baseline design language on all platforms per `docs/UI.md`
- Use Flutter adaptive constructors (`Switch.adaptive`, `Slider.adaptive`) per `docs/RESPONSIVENESS.md`
- Platform-specific UI divergence only for OS-mandated patterns (iOS swipe-back gesture, Android system back button) per `docs/PLATFORMS.md`
- Do NOT import `cupertino.dart` for general styling; Material 3 is the single design language

## Responsiveness

- [ ] ensure layouts adapt to screen sizes
- [ ] avoid platform-specific fixed dimensions
- [ ] test orientation changes
- [ ] use adaptive constructors instead of separate Cupertino widgets

---

# 7. State Management Integration

## Riverpod Usage

- [ ] platform services injected via providers
- [ ] platform differences hidden behind interfaces
- [ ] no platform logic in widgets

## Provider Rules

- [ ] use overrides for platform-specific implementations
- [ ] ensure deterministic behavior in tests
- [ ] avoid platform branching in UI layer

---

# 8. Testing Requirements

## Platform Testing

- [ ] test Android emulator/device
- [ ] test iOS simulator/device
- [ ] test web build (if supported)
- [ ] test fallback behavior on unsupported platforms

## Permission Testing

- [ ] granted flow
- [ ] denied flow
- [ ] permanently denied flow

## Edge Cases

- [ ] offline behavior
- [ ] missing capability behavior
- [ ] API failure per platform

---

# 9. Performance Considerations

- [ ] avoid repeated platform checks in build methods
- [ ] cache platform capability results where appropriate
- [ ] avoid platform branching in hot UI paths
- [ ] ensure no platform-specific jank differences

---

# 10. Security Considerations

- [ ] validate platform inputs
- [ ] never trust platform-provided data blindly
- [ ] handle permission abuse scenarios
- [ ] secure platform channels if used
- [ ] avoid exposing sensitive platform APIs to UI layer

---

# 11. Common Anti-Patterns

## MUST NOT

- [ ] scatter `Platform.isX` across widgets
- [ ] bypass abstraction layer for convenience
- [ ] assume permissions are granted
- [ ] implement platform logic in domain layer
- [ ] duplicate logic across platform files unnecessarily

## SHOULD AVOID

- [ ] excessive conditional imports
- [ ] over-engineered platform abstractions
- [ ] platform-specific UI divergence without justification

---

# 12. Documentation Requirements

- [ ] document platform behavior in feature docs
- [ ] document unsupported features clearly
- [ ] document fallback behavior
- [ ] document permission requirements

---

# 13. Validation Checklist

Before committing:

- [ ] platform behavior verified per target
- [ ] permissions tested
- [ ] fallback behavior verified
- [ ] abstraction layer respected
- [ ] tests pass
- [ ] preflight passes

Run:

```bash id="platform1"
make preflight
```

---

# 14. Output Expectations

When implementing platform-specific logic, provide:

## Platform Summary
- supported platforms
- differences per platform

## Architecture Notes
- interfaces introduced
- implementations per platform
- injection strategy

## Risk Assessment
- platform gaps
- permission risks
- fallback risks

## Testing Results
- platforms tested
- edge cases verified
