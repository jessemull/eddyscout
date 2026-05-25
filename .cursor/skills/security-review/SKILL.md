---
name: security-review
description: >-
  Audit and review security for EddyScout: authentication, storage,
  network, input validation, dependencies, and platform channels. Use
  when handling sensitive data, adding dependencies, or reviewing
  security-critical code.
---

# Security Review

Read the following before implementing or reviewing any security-sensitive changes:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/SECURITY.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/DEPENDENCIES.md`
- `docs/PLATFORMS.md`
- `docs/TESTING.md`

Companion skills:
- `dependency-upgrade` — package evaluation and vulnerability checks
- `testing` — security-related test coverage
- `riverpod-usage` — auth state isolation and provider security

Security is a **system-wide constraint**, not a feature layer.

All code must assume:
- untrusted network input
- compromised client environment (mobile/web)
- malicious or malformed API responses
- reverse-engineering risk on mobile apps

---

# When to Use

Use this skill when:

- handling authentication or authorization
- storing or retrieving sensitive data
- making network requests
- adding new dependencies
- using platform channels or native APIs
- handling user input
- logging or analytics
- implementing payments or identity flows
- configuring storage (secure storage, local DBs)
- exposing APIs or internal state to UI

---

# Core Security Principles

## Never Trust the Client

- all API responses are untrusted
- all local storage is modifiable by users
- all runtime state can be inspected or altered
- obfuscation is not a security boundary

---

## Security Must Be Layered

Security must exist in:
- backend (primary enforcement)
- data layer (validation + sanitization)
- domain layer (business rules)
- UI layer (safe display only)

UI is never a security boundary.

---

## Least Privilege Always

- request only required permissions
- access only required data
- expose only required state
- minimize persistent storage of sensitive data

---

# 1. Authentication & Authorization

## Authentication Rules

- [ ] tokens must never be hardcoded
- [ ] tokens must be stored in secure storage (e.g. `flutter_secure_storage`)
- [ ] tokens must be refreshed safely and automatically
- [ ] session expiration must be handled gracefully
- [ ] logout must fully clear all sensitive state

## Authorization Rules

- [ ] enforce access control on backend
- [ ] do not rely on UI hiding for security
- [ ] verify permissions in domain/data layer
- [ ] handle unauthorized responses (401/403)

---

# 2. Secure Storage

## Allowed Storage

- secure storage (tokens, credentials)
- encrypted local DB (sensitive cached data)

## Forbidden Storage

- plaintext storage of:
  - tokens
  - passwords
  - PII
  - session identifiers

## Rules

- [ ] assume local storage can be inspected
- [ ] encrypt sensitive data at rest
- [ ] clear storage on logout or revocation

---

# 3. Network Security

## Transport Rules

- [ ] HTTPS only (no exceptions)
- [ ] certificate validation must not be disabled
- [ ] no insecure HTTP fallbacks in production

## API Rules

- [ ] validate all API responses
- [ ] handle malformed JSON safely
- [ ] never trust server-provided UI flags blindly
- [ ] implement retry/backoff safely (avoid abuse loops)

---

# 4. Input Validation & Sanitization

## Rules

- [ ] validate all user input at entry points
- [ ] enforce domain-level validation
- [ ] sanitize before display where needed
- [ ] reject malformed or unexpected data early

## UI Safety

- [ ] prevent injection into rich text displays
- [ ] avoid rendering raw HTML unless sanitized
- [ ] ensure formatting cannot break layout or logic

---

# 5. Dependency Security

## Evaluation Required

Before adding/upgrading dependencies:

- [ ] verify maintainer activity
- [ ] check vulnerability reports
- [ ] confirm license compatibility
- [ ] review transitive dependencies
- [ ] ensure Flutter/Dart compatibility

## Rules

- [ ] avoid abandoned packages
- [ ] avoid excessive dependency chains
- [ ] prefer official Flutter/Dart ecosystem packages
- [ ] lock versions where appropriate

---

# 6. Logging & Observability

## Sensitive Data Rules

- [ ] never log:
  - tokens
  - passwords
  - personal data (PII)
  - authentication headers
- [ ] redact sensitive fields in logs

## Safe Logging

- [ ] log errors without sensitive payloads
- [ ] include correlation IDs where possible
- [ ] separate debug vs production logging behavior

---

# 7. Platform Security (Flutter-Specific)

## Platform Channels

- [ ] validate all data crossing platform boundary
- [ ] assume native code may be compromised
- [ ] sanitize inputs/outputs on both sides

## Mobile Risks

- [ ] assume device can be rooted/jailbroken
- [ ] assume app memory can be inspected
- [ ] do not store secrets in memory longer than necessary

## Web Risks (if applicable)

- [ ] avoid exposing sensitive logic in client JS
- [ ] assume full code visibility

---

# 8. State Management Security (Riverpod)

- [ ] do not expose sensitive state globally
- [ ] avoid caching secrets in providers
- [ ] isolate auth state from UI state
- [ ] clear providers on logout/session expiry
- [ ] prevent accidental state persistence across sessions

---

# 9. Data Privacy

- [ ] collect only necessary user data
- [ ] avoid storing PII unless required
- [ ] provide safe deletion mechanisms
- [ ] comply with platform privacy expectations

---

# 10. Error Handling Security

- [ ] do not expose stack traces to end users
- [ ] sanitize error messages
- [ ] avoid leaking backend structure in errors
- [ ] distinguish user-safe vs developer errors

---

# 11. Common Vulnerabilities to Prevent

## MUST NOT

- [ ] store secrets in plain text
- [ ] bypass authentication checks in UI
- [ ] trust client-side authorization decisions
- [ ] log sensitive data
- [ ] expose internal API structure to UI
- [ ] disable TLS validation
- [ ] ignore dependency vulnerabilities

## SHOULD AVOID

- [ ] over-permissive API responses
- [ ] excessive data exposure in models
- [ ] long-lived in-memory secrets
- [ ] unnecessary persistence of sensitive state

---

# 12. Security Validation Checklist

Before committing:

- [ ] authentication flows validated
- [ ] secure storage used correctly
- [ ] no secrets in logs or state
- [ ] dependencies reviewed
- [ ] input validation applied
- [ ] network layer secure
- [ ] platform boundaries validated
- [ ] tests pass
- [ ] preflight passes

Run:

```bash
make preflight
```

---

# 13. Output Expectations

When completing a security review, provide:

## Risk Summary
- identified vulnerabilities
- severity level

## Attack Surface Review
- network
- storage
- UI
- platform channels

## Mitigations Applied
- fixes implemented
- defensive improvements

## Residual Risk
- accepted risks (if any)
- justification