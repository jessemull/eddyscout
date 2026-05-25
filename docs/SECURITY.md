# Security

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **SECURITY.md** > inline comments.
>
> **AI agents — read this file when:** handling secrets, adding platform permissions, implementing authentication, working with user data, adding network calls, or touching WebView or deep link code.

---

## Secrets handling

### Never hardcode secrets

No API keys, tokens, passwords, signing keys, or service account credentials in source code. This includes:

- Dart source files
- Configuration files committed to git
- Test fixtures
- Comments or documentation
- CI workflow files (use repository secrets)

### Approved secret injection methods

| Method | Use case |
|--------|----------|
| `--dart-define` / `--dart-define-from-file` | Build-time config (Mapbox token, API base URLs) |
| `.local.env` (git-ignored) | Local development secrets |
| Platform secure storage (Keychain / Keystore) | Runtime secrets that persist on-device |
| CI repository secrets / environment variables | Build and deploy pipelines |
| Firebase Remote Config (non-sensitive only) | Feature flags, non-secret runtime config |

### `.local.env` rules

- **Never committed.** Must be in `.gitignore`.
- Each developer creates their own from [`apps/eddyscout/env.example`](../apps/eddyscout/env.example) (committed template with placeholder values):

  ```bash
  cd apps/eddyscout && cp env.example .local.env
  ```

- Contains only development keys. Production keys are managed via CI secrets and build-time injection.

---

## Secure storage requirements

### What requires secure storage

- Authentication tokens (access tokens, refresh tokens)
- Session identifiers
- User credentials (if ever stored locally)
- Encryption keys

### Implementation

- Use `flutter_secure_storage` or the platform-native Keychain (iOS) / Keystore (Android) APIs.
- Wrap secure storage behind an abstraction in `packages/persistence/` so the app never calls platform APIs directly.
- All secure storage access must be asynchronous (`Future`-based).
- Handle storage failures gracefully — secure storage can fail (device locked, biometric required).

### What does NOT require secure storage

- User preferences (theme, skill level) → `SharedPreferences`
- Cached API responses → drift database or file cache
- Non-sensitive feature flags → in-memory or prefs

---

## Unsafe logging restrictions

### Forbidden in log output

- API keys or tokens (Mapbox, Firebase, any third-party)
- User authentication tokens (access, refresh, session)
- PII: email, name, phone, device identifiers that can be correlated to a user
- Passwords or password hashes
- Full HTTP request/response bodies containing any of the above
- Firebase Cloud Messaging tokens
- Precise user location (lat/lng at high precision)

### Allowed in log output

- Error messages and stack traces (scrubbed of secrets)
- HTTP status codes and endpoint paths (without query params containing tokens)
- Feature flags and non-sensitive config values
- Anonymized identifiers (hashed, not reversible)
- General flow logging ("Fetching conditions for launch X")

### Enforcement

- Use a logging wrapper that redacts known sensitive patterns.
- Code review must check `log()`, `print()`, and `debugPrint()` calls for secrets.
- Debug-only logging (`lib/debug/`) must be gated behind `kDebugMode` or equivalent.

---

## Dependency auditing

### Before adding a dependency

1. **Check pub.dev score** — prefer packages with verified publishers and scores above 100.
2. **Review the license** — MIT, BSD, Apache 2.0 are acceptable. GPL is not for app-level code.
3. **Check maintenance status** — last publish date within 12 months, responsive to issues.
4. **Audit transitive dependencies** — `dart pub deps --style=tree` to verify no unexpected packages.
5. **Review permissions** — does the package request platform permissions? Are they justified?

### Ongoing

- Run `dart pub outdated` periodically and update dependencies.
- When a security advisory is published for a dependency, update within 1 business week for critical severity, 2 weeks for high, and 1 month for medium/low.
- Pin major versions with caret (`^`) to get patches while avoiding breaking changes.

---

## Platform permission rules

### Principle of least privilege

Request only the permissions the app actively uses. Remove permissions that are no longer needed.

### Current justified permissions

| Permission | Platform | Justification |
|------------|----------|---------------|
| Internet | Both | API calls to USGS, NOAA, NWS, Firebase, Mapbox |
| Fine location | Both | User position on map, bearing to waypoints |
| Coarse location | Both | Fallback when fine location is denied |

### Permission request rules

1. **Just-in-time:** Request permissions when the feature needs them, not at app startup.
2. **Explain first:** Show a rationale dialog before the system permission prompt.
3. **Degrade gracefully:** If permission is denied, the feature is disabled with a clear message — the app does not crash or nag.
4. **No background location** unless explicitly scoped as a product feature with user consent.
5. **Review platform manifests** (`AndroidManifest.xml`, `Info.plist`) in every PR that touches platform projects.

---

## WebView restrictions

If WebViews are introduced (e.g., for OAuth flows or content display):

1. **Disable JavaScript** unless the content explicitly requires it.
2. **Restrict navigation** — allow only the intended domain(s). Block navigation to arbitrary URLs.
3. **No `javaScriptMode: JavaScriptMode.unrestricted`** without a documented security review.
4. **Sanitize URLs** passed to WebViews — no user-controlled strings without validation.
5. **Do not pass tokens via URL parameters** — use HTTP headers or secure cookies.
6. **Use `WebViewCookieManager`** to clear session data when the WebView is dismissed.

---

## Deep link validation

1. **Validate all incoming deep link URLs** before navigating. Reject malformed or unexpected schemes/hosts/paths.
2. **Do not extract and use parameters from deep links without sanitization.** Treat all deep link parameters as untrusted input.
3. **Define an allowlist of valid deep link patterns** in go_router configuration. Unmatched links should redirect to a safe default (home screen), not crash.
4. **Log unrecognized deep links** (without the full URL if it may contain tokens) for monitoring.
5. **Test deep links** with malicious payloads (path traversal, script injection, excessively long strings).

---

## TLS expectations

- **All network communication must use HTTPS.** No HTTP endpoints in production.
- **Certificate pinning** is recommended for critical APIs (authentication, payment) if introduced later. Not required for public data APIs (USGS, NOAA).
- **Do not disable certificate validation** in any environment, including debug. If a development server requires it, use a local proxy (Charles, mitmproxy) with a locally trusted CA.
- **dio interceptors** must not downgrade HTTPS to HTTP or log full TLS handshake details.

---

## Input sanitization

### User input

- Sanitize all user-generated text before:
  - Sending to APIs (condition reports, chat messages)
  - Displaying in UI (prevent layout injection with excessively long strings)
  - Storing in local database
- Strip or escape HTML/script content in user text input.
- Enforce length limits on all text fields (both client-side and in Firebase Functions).

### API responses

- Validate response shapes before parsing. Malformed responses should fail gracefully, not crash.
- Do not trust API responses to be well-formed — use try/catch around JSON parsing.
- Treat all external data as potentially hostile.

---

## Authentication and authorization patterns

### Current state

- **Firebase Anonymous Auth** for callable function access.
- No user identity beyond anonymous session.

### When identity is added

1. **Tokens stored in secure storage** (Keychain / Keystore), never in SharedPreferences.
2. **Token refresh** handled transparently by a dio interceptor — the app never manually manages token expiry.
3. **Auth state managed via Riverpod** — a single `authProvider` as the source of truth.
4. **Route guards** in go_router redirect unauthenticated users to login.
5. **Server-side authorization** for all data mutations — client-side checks are UX only, not security.
6. **Session invalidation** on logout must clear:
   - Secure storage tokens
   - In-memory auth state
   - Relevant cached data
   - Firebase anonymous session (re-created on next use if needed)

---

## Security review triggers

The following changes **always** require a security-focused review (see `GOVERNANCE.md`):

- Any change to authentication or authorization logic
- New platform permissions
- New network endpoints or API clients
- Changes to secret injection or storage
- Introduction of WebViews
- Deep link configuration changes
- Changes to Firebase security rules
- New dependencies that access network, storage, or device APIs
- Changes to logging that might expose sensitive data
