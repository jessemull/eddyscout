# EddyScout — Error Handling Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when writing error handling code; when creating, modifying, or reviewing try/catch blocks; when designing failure types; when implementing async UI states; or when adding logging or crash reporting.

---

## Result Pattern for Expected Errors

Use a **`Result<T, E>`** (or equivalent sealed union) for operations that can fail in expected, recoverable ways — network calls, parsing, validation, file I/O.

```dart
sealed class Result<T, E> {
  const Result();
}

final class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;
}

final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;
}
```

- Return `Result` rather than throwing for business-logic errors.
- Reserve `throw` for truly exceptional, unrecoverable situations (programmer errors, corrupted state).

## Exception Handling Strategy

**Catch at boundaries, not everywhere.**

| Layer | Strategy |
|-------|----------|
| **Repository / data source** | Catch platform exceptions (`DioException`, `SqliteException`, etc.) and convert to domain `AppFailure` values |
| **Service / use-case** | Propagate `Result` — do not add another try/catch unless transforming the failure type |
| **UI (provider / controller)** | Expose `AsyncValue` or equivalent; the widget tree reacts to states, never catches |
| **Top-level** | `FlutterError.onError` and `PlatformDispatcher.instance.onError` for uncaught exceptions → crash reporting |

**Never** silently swallow exceptions with an empty `catch` block.

## AppFailure Sealed Hierarchy

Define a single sealed class as the canonical failure type across the app:

```dart
sealed class AppFailure {
  const AppFailure({this.message, this.stackTrace});
  final String? message;
  final StackTrace? stackTrace;
}

final class NetworkFailure extends AppFailure { ... }
final class ServerFailure extends AppFailure { ... }
final class CacheFailure extends AppFailure { ... }
final class ParseFailure extends AppFailure { ... }
final class PermissionFailure extends AppFailure { ... }
final class NotFoundFailure extends AppFailure { ... }
final class UnknownFailure extends AppFailure { ... }
```

- Every failure subclass must carry enough context for both logging and user-facing messaging.
- Map each subclass to a user-friendly string via a dedicated extension or l10n key — **never** show raw exception messages to users.

## Error UI Requirements

Every async state in the UI **must** handle all four states:

| State | Requirement |
|-------|-------------|
| **Loading** | Show a shimmer, skeleton, or spinner — never a blank screen |
| **Error** | Show a user-friendly message with a retry action when applicable |
| **Empty** | Show an informative empty state — never a blank container |
| **Data** | Show the content |

Use Riverpod's `AsyncValue.when()` (or `.map()`) to enforce exhaustive handling at compile time.

## Crash Reporting

- Integrate a crash reporting service (e.g., Firebase Crashlytics or Sentry) for production builds.
- All uncaught exceptions and fatal framework errors must be forwarded to the crash reporter.
- Include the current route, device info, and app version in every crash report.
- **Never** include PII in crash reports (see logging rules below).

## Error Logging Rules

| Rule | Detail |
|------|--------|
| **No PII** | Never log emails, phone numbers, names, precise coordinates, auth tokens, or passwords |
| **Include stack traces** | Always attach `StackTrace` when converting exceptions to `AppFailure` |
| **Structured context** | Log the operation name, failure type, and relevant IDs (launch ID, route ID) — not raw request/response bodies |
| **Log levels** | `severe` for crashes; `warning` for handled but unexpected failures; `info` for retries; `fine` for diagnostics |
| **Production vs. debug** | Verbose logs in debug only; structured, minimal logs in production |

## Retry Patterns

- Use **exponential backoff with jitter** for transient network failures.
- Cap retries at **3 attempts** by default.
- Expose a manual "Retry" action in the UI for user-initiated recovery.
- Never auto-retry non-idempotent operations (writes, submissions) without user confirmation.

## Graceful Degradation

When a subsystem fails, the app should remain usable:

| Scenario | Degraded behavior |
|----------|-------------------|
| Weather API unavailable | Show cached data with a staleness indicator; hide weather section if no cache exists |
| USGS flow API unavailable | Show "Flow data unavailable" instead of the flow widget |
| Crash reporter unreachable | Queue reports locally; flush on next successful connection |
| LLM summary fails | Hide summary card; show "Summary unavailable — tap to retry" |
| Offline | Serve cached content where available; clearly indicate offline status |

Never crash or show an unrecoverable error screen because a single non-critical data source is unreachable.
