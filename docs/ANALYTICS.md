# EddyScout — Analytics Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when implementing analytics events; when adding screen tracking; when defining event names or properties; when handling user data in analytics contexts; or when reviewing analytics code for privacy compliance.

---

## Analytics Abstraction Layer

All analytics calls go through an **`AnalyticsClient`** interface. No widget, provider, or service should call a specific analytics SDK directly.

```dart
abstract interface class AnalyticsClient {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> setScreen(String screenName);
  Future<void> setUserId(String? userId);
  Future<void> setUserProperty(String name, String value);
}
```

- Implementations wrap specific SDKs (e.g., Firebase Analytics, Mixpanel, Amplitude).
- Swap implementations without changing call sites.
- Use a **`NoOpAnalyticsClient`** in tests and when analytics are disabled.

## Event Naming Conventions

| Rule | Example |
|------|---------|
| **snake_case** | `view_launch_detail`, `tap_go_nogo_card` |
| **verb_noun** format | `select_skill_level`, `submit_condition_report` |
| **Max 40 characters** | Keep names concise but descriptive |
| **No PII in event names** | Never embed user-specific data in the event name itself |

Prefix events by domain when helpful for filtering:

- `nav_` — navigation events
- `map_` — map interaction events
- `report_` — condition report events

## Screen Tracking Standards

- Every routed screen logs a screen view event via `AnalyticsClient.setScreen()`.
- Screen names match route names or descriptive constants, not widget class names.
- Track screen views in the router observer, not manually in each screen widget.

```dart
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._client);
  final AnalyticsClient _client;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name != null) {
      _client.setScreen(route.settings.name!);
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

**Allowed:** Anonymized user IDs, coarse location (city-level or region), device model, OS version, app version.

## Event Taxonomy

Categorize events for organized dashboards and analysis:

| Category | Purpose | Examples |
|----------|---------|---------|
| **Navigation** | Screen views, tab switches, deep links | `nav_to_launch_detail`, `nav_back_to_map` |
| **Interaction** | User taps, gestures, selections | `tap_launch_pin`, `select_skill_level` |
| **Conversion** | Goal completions, feature adoption | `submit_condition_report`, `complete_onboarding` |
| **Error** | User-facing errors, failures | `error_weather_load`, `error_report_submit` |

## Consent Management

- Analytics must respect the user's consent preferences.
- On first launch, present a clear consent prompt if required by jurisdiction (GDPR, CCPA).
- Provide a settings toggle to opt out of analytics at any time.
- When consent is revoked, stop sending events **immediately** and delete any locally queued events.
- The `AnalyticsClient` implementation must check consent state before dispatching any event.

## Debug vs. Production Analytics

| Environment | Behavior |
|-------------|----------|
| **Debug** | Log events to console via `debugPrint`; do **not** send to production analytics backends |
| **Profile** | Optionally send to a staging analytics project |
| **Release** | Send to the production analytics project |

- Use `kDebugMode` or build flavor to switch `AnalyticsClient` implementations.
- Debug logging should include event name and all parameters for easy verification.

## Analytics Testing Strategy

- **Unit tests:** Verify that interactions trigger the expected events by injecting a mock `AnalyticsClient`.
- **Integration tests:** Confirm screen tracking fires on navigation.
- **Event audit:** Periodically review the event catalog against the analytics dashboard to identify dead or missing events.
- **Privacy tests:** Add lint rules or review checks to flag potential PII in event parameters.
