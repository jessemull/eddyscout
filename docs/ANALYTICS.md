# EddyScout — Analytics Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when implementing analytics events; when adding screen tracking; when defining event names or properties; when handling user data in analytics contexts; or when reviewing analytics code for privacy compliance.

---

## Analytics Abstraction Layer

All analytics calls go through an **`AnalyticsClient`** interface. No widget, provider, or service should call a specific analytics SDK directly.

```dart
abstract class AnalyticsClient {
  Future<void> logEvent(AnalyticsEvent event);
  Future<void> logScreenView({required String screenName});
  Future<void> setUserProperty({required String name, required String value});
  Future<void> flush();
}
```

- Implementations wrap specific SDKs (e.g., Firebase Analytics, Mixpanel, Amplitude) when added later.
- Swap implementations without changing call sites.
- **`NoOpAnalyticsClient`** — release builds and tests when telemetry must not leave the device.
- **`DebugAnalyticsClient`** — debug builds; logs to console via `debugPrint` only.

Access the client via Riverpod: `ref.read(analyticsClientProvider)`.

## v1 implementation (shipped)

| Component | Location |
|-----------|----------|
| Client interface + events | `packages/analytics/` |
| Screen name mapping | `AnalyticsScreenNames.fromMatchedLocation()` |
| Router screen tracking | `apps/eddyscout/lib/analytics/analytics_navigator_observer.dart` |
| App wiring | `main.dart` overrides `navigatorObserversProvider` |

Third-party analytics SDKs are **not** wired yet. Consent UI is deferred — see Consent Management below.

## When to add analytics

| Change | Required analytics |
|--------|-------------------|
| **New routed screen** | Add path to `AnalyticsScreenNames` — screen view is automatic via router observer |
| **New conversion / goal** (submit, save, complete flow) | Add `AnalyticsEvent` using constants in `AnalyticsEvents` |
| **Domain/data-only refactor** | None |
| **Every button tap** | Do **not** add — avoid event spam |

## Event Naming Conventions

| Rule | Example |
|------|---------|
| **snake_case** | `report_submit_success`, `route_planned` |
| **verb_noun** format | `select_skill_level`, `submit_condition_report` |
| **Max 40 characters** | Keep names concise but descriptive |
| **No PII in event names** | Never embed user-specific data in the event name itself |

Prefix events by domain when helpful for filtering:

- `nav_` — navigation events
- `map_` — map interaction events
- `report_` — condition report events

## Screen Tracking Standards

- Every routed screen logs a screen view via `AnalyticsClient.logScreenView`.
- Screen names use constants in `AnalyticsScreenNames`, not widget class names.
- Track screen views in **`AnalyticsNavigatorObserver`**, not manually in each screen widget.
- When adding a route in `apps/eddyscout/lib/routing/app_routes.dart`, extend `AnalyticsScreenNames.fromMatchedLocation`.

```dart
class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver(this._client);
  final AnalyticsClient _client;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final context = route.navigator?.context;
    if (context == null || !context.mounted) return;
    final screenName = AnalyticsScreenNames.fromMatchedLocation(
      GoRouter.of(context).state.matchedLocation,
    );
    if (screenName != null) {
      _client.logScreenView(screenName: screenName);
    }
  }
}
```

## Privacy Restrictions

### NEVER log PII

Analytics events and properties must **never** contain personally identifiable information.

### PII Definition

The following are considered PII and must not appear in analytics payloads:

| Category | Examples |
|----------|---------|
| **Contact info** | Email address, phone number |
| **Identity** | Full name, username (if personally identifiable) |
| **Location** | GPS coordinates at high precision (> 2 decimal places), street address, IP address |
| **Authentication** | Auth tokens, session IDs, passwords |
| **Device identifiers** | IMEI, MAC address (advertising ID only with consent) |
| **Financial** | Payment card numbers, bank accounts |
| **User content** | Condition report message text, free-form notes |

**Allowed:** Opaque launch ids, coarse location (city-level or region), device model, OS version, app version.

## Event Taxonomy

Categorize events for organized dashboards and analysis:

| Category | Purpose | Examples |
|----------|---------|---------|
| **Navigation** | Screen views, tab switches, deep links | `screen_map`, `screen_launch_detail` |
| **Interaction** | User taps, gestures, selections | `tap_launch_pin`, `select_skill_level` |
| **Conversion** | Goal completions, feature adoption | `report_submit_success`, `complete_onboarding` |
| **Error** | User-facing errors, failures | `error_weather_load`, `error_report_submit` |

## Consent Management

- Analytics must respect the user's consent preferences when a consent UI ships.
- **v1:** No consent prompt — debug client logs locally only; release uses `NoOpAnalyticsClient`.
- **Future:** On first launch, present a clear consent prompt if required by jurisdiction (GDPR, CCPA). Gate SDK implementations behind consent; `NoOpAnalyticsClient` when opted out.

## Debug vs. Production Analytics

| Environment | Behavior |
|-------------|----------|
| **Debug** | `DebugAnalyticsClient` — log events to console via `debugPrint`; do **not** send to production backends |
| **Release** | `NoOpAnalyticsClient` until a production SDK adapter is added |

- Use `kDebugMode` in `analyticsClientProvider` to select the implementation.
- When a production SDK is added, swap the release binding only — call sites stay unchanged.

## Analytics Testing Strategy

- **Unit tests:** Inject a recording/fake `AnalyticsClient` via `analyticsClientProvider.overrideWithValue`.
- **Widget tests:** Assert conversion events on goal completions (see `report_submit_analytics_test.dart`).
- **Integration tests:** Confirm screen tracking fires on navigation when E2E journeys are added.
- **Privacy tests:** Review PRs for PII in event parameters; never log report text or tokens.
