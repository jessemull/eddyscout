---
name: dependency-upgrade
description: >-
  Add, upgrade, or remove dependencies in EddyScout. Use when modifying
  pubspec.yaml, evaluating packages, resolving conflicts, or updating
  SDK constraints.
---

# Dependency Upgrade

Read the following before modifying dependencies:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/DEPENDENCIES.md`
- `docs/ARCHITECTURE.md`
- `docs/SECURITY.md`
- `docs/PERFORMANCE.md`
- `docs/CODEGEN.md`

**MUST:** New packages not on the approved list in `docs/DEPENDENCIES.md` require human PR approval before merge. Do not add dependencies without human approval (per `AGENTS.md`). Follow the approval process in `docs/DEPENDENCIES.md` §Process for Requesting New Dependencies.

**Banned packages** (per `docs/DEPENDENCIES.md`): `provider`, `get_it`, `injectable`, and packages with unnecessary native code. See the full banned list in that document.

Dependencies are one of the highest-risk areas in the repository.

Every dependency:
- increases maintenance burden
- expands attack surface
- affects binary size
- affects performance
- affects CI stability
- affects platform compatibility
- affects long-term architecture

Dependencies must be added intentionally and conservatively.

Default philosophy:
- prefer fewer dependencies
- prefer mature dependencies
- prefer explicit architecture ownership
- prefer repository-controlled abstractions
- avoid dependency sprawl

---

# When to Use

Use this skill when:

- adding dependencies
- upgrading dependencies
- removing dependencies
- changing dependency constraints
- updating Flutter SDK constraints
- updating Dart SDK constraints
- resolving dependency conflicts
- modifying build tooling dependencies
- modifying code generation dependencies
- evaluating package replacements

This applies to:
- `dependencies`
- `dev_dependencies`
- `dependency_overrides`

in any `pubspec.yaml`.

---

# Core Dependency Principles

## Minimize Dependency Count

Every dependency:
- adds complexity
- adds transitive dependencies
- increases upgrade burden
- increases security risk
- increases binary size

Prefer:
- existing repository utilities
- standard library solutions
- Flutter SDK capabilities
- lightweight focused packages

before introducing new dependencies.

---

## Prefer Stable Ecosystem Packages

Prefer packages that are:
- mature
- actively maintained
- widely adopted
- stable
- well-documented
- Dart 3 compatible
- null-safe
- platform-compatible

Avoid:
- abandoned packages
- experimental packages
- low-quality packages
- poorly maintained wrappers
- unnecessary abstraction libraries

---

## Repository Consistency Matters

Prefer:
- existing repository patterns
- approved ecosystem choices
- architecture consistency

Avoid:
- introducing competing libraries
- duplicate functionality
- fragmented architecture approaches

Examples:
- do not introduce a second networking stack
- do not introduce multiple state management systems
- do not introduce competing routing systems

---

# 1. Dependency Classification

Classify the dependency change.

## Change Types

- [ ] new runtime dependency
- [ ] new dev dependency
- [ ] dependency upgrade
- [ ] dependency removal
- [ ] SDK upgrade
- [ ] transitive dependency override
- [ ] build tooling dependency
- [ ] code generation dependency
- [ ] platform integration dependency

## Risk Level

- [ ] low risk
- [ ] medium risk
- [ ] high risk
- [ ] critical risk

High-risk examples:
- networking libraries
- auth/security libraries
- state management libraries
- persistence libraries
- platform channel libraries
- core architecture libraries

---

# 2. Approved Dependency Review

Before adding or upgrading:

- [ ] Read `docs/DEPENDENCIES.md`
- [ ] Verify package is approved
- [ ] Verify package version policy
- [ ] Verify package ownership conventions
- [ ] Verify repository alternatives do not already exist

If package is not approved:
- escalate for human review
- document justification
- document architectural impact

---

# 3. Package Evaluation

## Maintenance Review

- [ ] Active maintenance within last 6 months
- [ ] Stable release cadence
- [ ] Open issues reviewed
- [ ] Breaking change frequency acceptable
- [ ] Maintainer responsiveness acceptable

## Ecosystem Quality

- [ ] High pub.dev quality score
- [ ] Strong documentation
- [ ] Strong community adoption
- [ ] Good ecosystem reputation
- [ ] Production usage evidence exists

## Compatibility

- [ ] Dart 3 compatible
- [ ] Null-safe
- [ ] Flutter version compatible
- [ ] Android compatible
- [ ] iOS compatible
- [ ] Web compatible where required
- [ ] Desktop compatible where required

## Licensing

Approved licenses only:

- MIT
- BSD
- Apache 2.0

Verify:
- [ ] license compatibility
- [ ] no restrictive clauses
- [ ] no problematic transitive licenses

---

# 4. Architecture Review

## Repository Consistency

- [ ] Dependency aligns with repository architecture
- [ ] Dependency does not duplicate existing capability
- [ ] Dependency does not conflict with existing stack
- [ ] Dependency boundaries clear

## Ownership

- [ ] Dependency usage isolated appropriately
- [ ] Dependency wrapped behind repository abstractions where appropriate
- [ ] Third-party APIs not leaked throughout codebase

## Abstraction Safety

Avoid exposing third-party APIs directly throughout application layers.

Prefer:
- adapters
- repository abstractions
- service interfaces
- wrapper utilities

---

# 5. Security Review

## Security Risk

- [ ] Package security reputation acceptable
- [ ] No known major CVEs
- [ ] Dependency not abandoned
- [ ] Dependency not suspicious/malicious

## Sensitive Capabilities

If dependency touches:
- auth
- encryption
- storage
- networking
- platform channels
- permissions

require additional scrutiny.

## Transitive Dependencies

- [ ] Transitive dependency tree reviewed
- [ ] No suspicious transitive packages
- [ ] No excessive dependency bloat

---

# 6. Performance & Binary Size Review

## Binary Size

- [ ] Binary size impact acceptable
- [ ] Native binary additions justified
- [ ] Platform SDK additions justified

## Runtime Performance

- [ ] No excessive runtime overhead
- [ ] No unnecessary reflection-heavy behavior
- [ ] No expensive startup initialization
- [ ] No known rebuild/performance issues

## Memory Usage

- [ ] Memory footprint acceptable
- [ ] Large caches/storage justified

---

# 7. Platform Compatibility Review

## Supported Platforms

Verify compatibility for required platforms:

- [ ] Android
- [ ] iOS
- [ ] Web
- [ ] macOS
- [ ] Windows
- [ ] Linux

## Platform Limitations

- [ ] Platform-specific caveats documented
- [ ] Permissions understood
- [ ] Native configuration understood
- [ ] Background execution implications reviewed

---

# 8. Dependency Versioning Strategy

## Version Constraints

Prefer caret constraints:

```yaml
dependencies:
  dio: ^5.7.0
```

Avoid:
- loose unbounded constraints
- outdated pinned versions without justification
- unnecessary dependency overrides

## SDK Constraints

If changing SDK versions:

- [ ] Flutter SDK compatibility reviewed
- [ ] Dart SDK compatibility reviewed
- [ ] CI compatibility reviewed
- [ ] toolchain compatibility reviewed

---

# 9. Upgrade Impact Review

## Changelog Review

- [ ] Changelog reviewed
- [ ] Breaking changes reviewed
- [ ] Migration steps documented
- [ ] Deprecated APIs identified

## API Impact

- [ ] Existing APIs still valid
- [ ] Behavioral changes reviewed
- [ ] Async behavior changes reviewed
- [ ] Serialization changes reviewed

## Architecture Impact

- [ ] Existing repository patterns preserved
- [ ] Dependency upgrade does not force architecture drift

---

# 10. Update pubspec.yaml

## Correct Package Placement

- [ ] Runtime dependency placed in `dependencies`
- [ ] Tooling dependency placed in `dev_dependencies`
- [ ] Overrides minimized and justified

## Workspace Integrity

- [ ] Correct package updated
- [ ] Monorepo consistency preserved
- [ ] Shared package versions aligned where appropriate

---

# 11. Dependency Resolution

Run:

```bash
dart pub get
```

Or workspace equivalent:

```bash
melos bootstrap
```

Verify:

- [ ] dependency graph resolves correctly
- [ ] no version conflicts
- [ ] no dependency override drift
- [ ] lockfiles updated intentionally

---

# 12. Code Generation Validation

If dependency affects:
- `freezed`
- Riverpod
- serialization
- routing
- build_runner

Run:

```bash
make gen
make gen-check
```

Verify:
- [ ] generated files updated
- [ ] no stale artifacts
- [ ] analyzer clean

---

# 13. Testing Validation

Run:

```bash
make test
make analyze
make preflight
```

Verify:

- [ ] unit tests pass
- [ ] widget tests pass
- [ ] integration tests pass
- [ ] analyzer clean
- [ ] formatting clean
- [ ] CI-compatible

---

# 14. Runtime Validation

## Manual Verification

Verify affected functionality manually.

Examples:
- navigation
- auth
- persistence
- networking
- animations
- platform integrations

## Performance Validation

- [ ] startup performance acceptable
- [ ] rebuild behavior acceptable
- [ ] memory usage acceptable
- [ ] no jank introduced

---

# 15. Documentation Updates

If dependency changes are accepted:

- [ ] update `docs/DEPENDENCIES.md`
- [ ] document approved version range
- [ ] document rationale
- [ ] document migration implications
- [ ] document platform caveats
- [ ] document architectural implications

---

# 16. Dependency Removal Review

When removing dependencies:

- [ ] unused code removed
- [ ] imports removed
- [ ] generated artifacts cleaned
- [ ] replacement architecture verified
- [ ] lockfile cleaned

Verify no orphaned:
- wrappers
- adapters
- providers
- utilities
- configs

remain.

---

# 17. AI-Assisted Dependency Validation

## AI Safety

- [ ] Package actually exists
- [ ] Package APIs verified
- [ ] No hallucinated packages
- [ ] No outdated examples copied blindly

## Repository Consistency

- [ ] Existing repository patterns reused
- [ ] Existing approved dependencies preferred
- [ ] Dependency count minimized

## Complexity Review

- [ ] Dependency justified versus custom implementation
- [ ] No unnecessary abstraction layers introduced
- [ ] No dependency duplication introduced

---

# 18. Common Dependency Anti-Patterns

## MUST NOT

- [ ] Add duplicate libraries solving same problem
- [ ] Add abandoned packages
- [ ] Add unmaintained packages
- [ ] Add insecure packages
- [ ] Use dependency_overrides casually
- [ ] Leak third-party APIs throughout app
- [ ] Commit unresolved dependency conflicts

## SHOULD AVOID

- [ ] Heavy abstraction libraries
- [ ] Large UI frameworks on top of Flutter
- [ ] Excessive codegen dependencies
- [ ] Massive transitive dependency trees
- [ ] Experimental packages in production

---

# 19. Final Dependency Checklist

Before merge:

- [ ] dependency approved
- [ ] architecture reviewed
- [ ] security reviewed
- [ ] performance reviewed
- [ ] platform support verified
- [ ] tests pass
- [ ] analyzer passes
- [ ] codegen passes
- [ ] documentation updated
- [ ] CI passes

---

# Output Expectations

When performing dependency work, provide:

## Dependency Summary
- packages changed
- versions changed
- affected packages/features

## Risk Assessment
- security implications
- performance implications
- architecture implications

## Validation Results
- tests run
- analyzer status
- codegen status
- CI status

## Migration Notes
- breaking changes
- required refactors
- rollout considerations