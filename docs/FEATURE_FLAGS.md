# EddyScout — Feature Flag Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when adding, checking, or removing feature flags; when configuring `--dart-define` or remote config values; when reviewing code gated behind feature flags; or when planning flag lifecycle and cleanup.

---

## Philosophy

**Decouple deployment from release.** Feature flags allow code to ship to production behind a gate, enabling:

- Incremental rollout without app store releases.
- A/B testing and experimentation.
- Kill switches for unstable features.
- Trunk-based development — merge incomplete features safely.

Every flag is **temporary by design**. Flags that remain in the codebase after full rollout are tech debt.

## Implementation Strategy

### Compile-Time Flags (`--dart-define`)

Use for features that must be resolved at build time:

```bash
flutter run --dart-define=ENABLE_FIREBASE=true
flutter build apk --dart-define=ENABLE_FIREBASE=true
```

Access in Dart:

```dart
const enableFirebase = bool.fromEnvironment('ENABLE_FIREBASE');
```

**Use cases:** Feature gates that affect initialization, platform-specific builds, CI-only features.

**Trade-off:** Requires a rebuild to change. Cannot be toggled at runtime.

### Runtime Flags (Remote Config)

Use for features that should be toggleable without a new build:

- Firebase Remote Config (or equivalent service) for production flags.
- Local override via debug settings screen for development.

```dart
abstract interface class FeatureFlagClient {
  bool isEnabled(String flagName);
  Future<void> refresh();
}
```

**Use cases:** Staged rollout, A/B tests, kill switches, user-segment targeting.

### Flag Priority

When both compile-time and runtime flags exist for the same feature:

1. Compile-time flag takes precedence if set to `false` (feature is hard-disabled).
2. Runtime flag controls behavior when compile-time flag is `true` or unset.

## Naming Conventions

| Rule | Example |
|------|---------|
| **SCREAMING_SNAKE_CASE** for `--dart-define` | `ENABLE_FIREBASE`, `ENABLE_CHAT` |
| **snake_case** for remote config keys | `enable_route_planner`, `show_ai_summary` |
| **Descriptive verb prefix** | `enable_`, `show_`, `use_`, `allow_` |
| **No negation** | `enable_chat` not `disable_chat` (avoid double-negative confusion) |

## Flag Lifecycle

Every feature flag follows a strict lifecycle:

```
Create → Develop → Test → Enable → Monitor → Remove
```

| Phase | Action |
|-------|--------|
| **Create** | Add flag with documentation (purpose, owner, target removal date) |
| **Develop** | Gate new code behind the flag; existing code paths remain the default |
| **Test** | Test both flag-on and flag-off paths; add tests for each |
| **Enable** | Roll out via staged percentages or full enable |
| **Monitor** | Observe metrics, crash rates, and user feedback during rollout |
| **Remove** | Delete the flag, remove conditional branches, delete flag-off code paths |

### Flag Registration

Maintain a registry of active flags (in code or a dedicated config file):

```dart
/// Active feature flags — remove after full rollout.
///
/// Flag: ENABLE_FIREBASE
/// Owner: @jessemull
/// Created: 2026-01-15
/// Target removal: 2026-04-01
/// Purpose: Gate Firebase integration until backend is stable.
```

## Testing with Feature Flags

- **Test both paths.** Every flagged code path must have tests for flag-on and flag-off states.
- **Default to off.** New flags default to disabled so that enabling is an explicit action.
- **Mock the flag client.** In tests, inject a mock `FeatureFlagClient` to control flag state deterministically.
- **CI runs with flags off.** Default CI runs test the flag-off path. A separate CI job or matrix entry tests with flags enabled.

## Cleanup Requirements

- Flags **must be removed** within **30 days** of full rollout (100% enabled, stable).
- Removal means:
  - Delete the flag constant or remote config key.
  - Remove all conditional branches — keep only the flag-on code path.
  - Delete the flag-off code path entirely.
  - Remove related tests that only test the flag-off path.
  - Update this document's registry.
- Stale flags (past their target removal date) are flagged in code review as blocking findings.
- Schedule a recurring monthly review to audit active flags against the registry.
