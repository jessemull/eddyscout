# Networking

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read this file when working with HTTP clients, dio configuration, API integrations, interceptors, retry logic, request cancellation, or debugging network-related issues.

---

## Package Boundaries

| Location | Responsibility |
|----------|---------------|
| `packages/networking/` | Dio factory, base interceptors, response types, HTTP client abstraction |
| Feature `data/` layer | Feature-specific HTTP wiring — provider creating and disposing a client, feature API calls |
| `packages/core/` | Domain types (`Result`, `AppFailure`) returned at repository boundaries |

- `packages/networking/` depends on `packages/core/` and `dio`. It must not depend on Flutter SDK unless required for interceptors.
- Feature packages depend on `packages/networking/` for the shared HTTP client but never import from other features.
- See `ARCHITECTURE.md` §Package Boundaries for the full dependency graph.

---

## Dio Factory & Interceptors

Infrastructure lives in `packages/networking/`. A `dioProvider` exposes the configured `Dio` instance via Riverpod:

```dart
@riverpod
Dio dio(Ref ref) => Dio(BaseOptions(baseUrl: 'https://api.example.com'));
```

Feature repositories receive the client through dependency injection:

```dart
@riverpod
ConditionsRepository conditionsRepository(Ref ref) {
  return ConditionsRepository(client: ref.watch(dioProvider));
}
```

See `STATE_MANAGEMENT.md` §Repository Integration Patterns for full examples.

### Interceptor Rules

- Interceptors must not downgrade HTTPS to HTTP.
- Interceptors must not log full request/response bodies in production.
- Interceptors must strip sensitive headers (`Authorization`, `Cookie`) from logged requests.
- Auth token refresh should be handled transparently by an interceptor when identity is added. See `SECURITY.md` §Authentication.

---

## Request Cancellation

From `AGENTS.md`:

- Use `CancelToken` with every dio request.
- Cancel in-flight requests when the widget/provider is disposed.
- Propagate cancellation through the use case and repository layers.

```dart
@riverpod
class ConditionsNotifier extends _$ConditionsNotifier {
  CancelToken? _cancelToken;

  @override
  Future<ConditionsSnapshot> build(LaunchPoint launch) {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    ref.onDispose(() => _cancelToken?.cancel());
    return _repository.fetch(launch, cancelToken: _cancelToken!);
  }
}
```

---

## Retry & Timeout Policy

From `AGENTS.md`:

| Parameter | Value |
|-----------|-------|
| Strategy | Exponential backoff |
| Base delay | 500ms |
| Multiplier | 2× |
| Max retries | 3 |
| Retry on | 5xx server errors, network connectivity errors |
| Do NOT retry | 4xx client errors (except 429 Too Many Requests with `Retry-After`) |

Configure timeouts on the `Dio` instance:

- Connect timeout: appropriate for mobile networks (e.g., 15s).
- Receive timeout: appropriate for expected payload sizes.
- Send timeout: appropriate for upload operations.

---

## Error Handling at Repository Boundary

Repositories catch `DioException` and convert to domain `AppFailure` values. Exceptions must not cross package boundaries.

```dart
Future<Result<ConditionsSnapshot, AppFailure>> fetch(LaunchPoint launch) async {
  try {
    final response = await _client.get('/conditions', queryParameters: {...});
    return Success(ConditionsSnapshot.fromJson(response.data));
  } on DioException catch (e, st) {
    return Failure(NetworkFailure(message: e.message, stackTrace: st));
  }
}
```

- Return `Result<T, AppFailure>` — never throw across package boundaries.
- Map `DioException` subtypes to appropriate `AppFailure` subclasses (`NetworkFailure`, `ServerFailure`, `NotFoundFailure`, etc.).
- See `ERROR_HANDLING.md` for the full `AppFailure` hierarchy and UI error state requirements.

---

## Caching

- Cache API responses in the repository layer, not in interceptors or providers.
- Invalidate cache on mutation (create, update, delete).
- Use stale-while-revalidate for non-critical data.
- Store cache timestamps for freshness checks.
- Show cached data when offline with a staleness indicator. See `AGENTS.md` §Offline Handling.

---

## Security

- **HTTPS everywhere.** No HTTP endpoints in production.
- **No secrets in source.** API keys come from `--dart-define` or platform-secure storage.
- **No PII or tokens in logs.** Ever. See `SECURITY.md`.
- **Certificate pinning** recommended for critical APIs (auth, payments) if introduced later.
- **Do not disable certificate validation** in any environment.

---

## Serialization

- All API models use `freezed` + `json_serializable`.
- DTO classes live in `data/`. Entity classes live in `domain/`.
- Mapping between DTO and Entity happens in the `data/` layer only.
- See `CODEGEN.md` for generation rules.

---

## Debugging Network Issues

When debugging network-related problems:

1. Inspect HTTP requests (method, URL, headers, body).
2. Verify retry behavior and backoff timing.
3. Verify `CancelToken` disposal and cancellation propagation.
4. Check auth state and token attachment.
5. Verify caching behavior and staleness.
6. Verify serialization round-trip correctness.

For structured debugging workflow, use the `debugging` skill (`.cursor/skills/debugging/SKILL.md`) §Network Tools.

---

## Related Documents

| Document | Scope |
|----------|-------|
| `ARCHITECTURE.md` | Package boundaries, dependency graph, `packages/networking/` placement |
| `STATE_MANAGEMENT.md` | `dioProvider`, repository integration patterns |
| `SECURITY.md` | HTTPS, TLS, interceptor logging, token handling |
| `ERROR_HANDLING.md` | `Result`, `AppFailure` hierarchy, error UI |
| `AGENTS.md` | Retry strategy, cancellation, caching, offline handling |
| `CODEGEN.md` | `freezed` + `json_serializable` for API models |
