# Security Review

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when auditing code for security issues or implementing security-sensitive features.

## References

- `docs/SECURITY.md` — security policy, secret management, vulnerability response

## Checklist

### 1. Hardcoded Secrets

- [ ] No API keys, tokens, or passwords in source code
- [ ] No secrets in `pubspec.yaml`, config files, or assets
- [ ] `.gitignore` excludes `.env`, `google-services.json`, `GoogleService-Info.plist`
- [ ] Secrets are loaded from environment variables or secure storage at runtime

### 2. Secure Storage

- [ ] Sensitive data uses `flutter_secure_storage` (not `SharedPreferences`)
- [ ] Auth tokens stored in secure storage, never in plain text
- [ ] Cached data does not include PII unless encrypted

### 3. Logging and PII

- [ ] No PII (names, emails, locations) in log output
- [ ] No auth tokens or session IDs in logs
- [ ] Debug logging is gated behind `kDebugMode` or build flavor
- [ ] Production crash reports scrub PII before sending

### 4. Network Security

- [ ] All API calls use HTTPS — no HTTP endpoints
- [ ] Certificate pinning considered for sensitive endpoints
- [ ] Auth tokens sent only in `Authorization` header, not query params
- [ ] Retry/error interceptors do not leak tokens in error messages

### 5. Deep Link Validation

- [ ] Deep link parameters are validated and sanitized
- [ ] No arbitrary navigation from untrusted deep link data
- [ ] Auth-gated routes verify authentication before rendering

### 6. Permissions

- [ ] Only request permissions that are strictly necessary
- [ ] Justify each permission in `AndroidManifest.xml` / `Info.plist`
- [ ] Handle permission denial gracefully with user messaging
- [ ] Review permission changes — these require human approval

### 7. Dependency Audit

- [ ] Review new dependencies for known vulnerabilities
- [ ] Check dependency license compatibility
- [ ] Prefer widely-used, actively-maintained packages
- [ ] Reference `docs/DEPENDENCIES.md` for the approved list
