# EddyScout — Dependency Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when adding, removing, upgrading, or evaluating any Dart/Flutter package; when reviewing `pubspec.yaml` changes; when proposing a new dependency; or when auditing transitive dependencies.

---

## Philosophy

Prefer **well-maintained, popular, strongly typed** packages over hand-rolled solutions. Every dependency is a long-term maintenance commitment — add one only when the cost of writing and maintaining the equivalent code in-house clearly exceeds the cost of the dependency.

## Package Evaluation Rubric

Before adding any package, score it against all five criteria:

| Criterion | Acceptable | Red flag |
|-----------|-----------|----------|
| **Maintenance** | ≥ 1 release in the last 6 months; responsive issue tracker | Abandoned, single anonymous maintainer |
| **Popularity** | pub.dev likes ≥ 100 _or_ endorsed by Dart/Flutter team | < 20 likes with no clear niche justification |
| **Null safety** | Full null-safe (sound) | Still on legacy null-safety shim |
| **License** | MIT, BSD-3, Apache-2.0 | GPL, AGPL, SSPL, or no license |
| **Size / deps** | Minimal transitive tree; no unnecessary native code | Pulls in dozens of transitive packages or large native blobs |

A package must pass **all five** criteria to be approved without escalation.

## Banned Dependency Patterns

| Package / pattern | Reason | Exception |
|-------------------|--------|-----------|
| `provider` | Riverpod is the project standard; mixing state management creates confusion | None |
| `get_it` / `injectable` | Service-locator pattern conflicts with Riverpod's compile-time DI | Justified in writing with tech-lead approval |
| Packages with native code (C/C++/ObjC/Swift/Kotlin) | Increases build complexity and platform-specific failure surface | Justified when no pure-Dart alternative exists (e.g., `sqflite` via Drift) |
| Packages that vendor a full web view for non-web-view features | Excessive bundle size and platform risk | None |

## Approved Packages

The following packages are pre-approved for use across the monorepo:

### Core framework
- `flutter` (stable channel)
- `dart` (≥ 3.0)

### State management & DI
- `flutter_riverpod` / `riverpod`
- `riverpod_annotation` + `riverpod_generator`

### Routing
- `go_router`
- `go_router_builder`

### Networking
- `dio`

### Serialization & models
- `freezed` + `freezed_annotation`
- `json_serializable` + `json_annotation`

### Local storage
- `drift` + `sqlite3_flutter_libs`

### Code generation
- `build_runner`

### Linting
- `very_good_analysis`
- `riverpod_lint` via `analysis_server_plugin` (see `tooling/analysis_options.base.yaml`; `custom_lint` not used)

### Theming
- Material 3 (`useMaterial3: true`)

### Monorepo tooling
- `melos`

### CI
- GitHub Actions

Packages not on this list require the approval process below.

## Process for Requesting New Dependencies

1. **Open an issue or PR description** with the package name, pub.dev link, and a brief justification.
2. **Score the package** against the evaluation rubric above; include the results.
3. **Document alternatives** considered and why they were rejected.
4. **Review transitive dependencies** — run `dart pub deps --style=compact` and note anything unexpected.
5. **Get approval** from at least one other contributor via PR review.
6. **Add the package** to the approved list in this file once merged.

## Dependency Update Workflow

| Cadence | Action |
|---------|--------|
| **Monthly** | Audit all direct dependencies for new major/minor versions; review changelogs |
| **Continuous** | Dependabot (or Renovate) PRs for patch-level updates |
| **Per update** | Review transitive dependency diff (`dart pub deps`) for unexpected additions |
| **Per major bump** | Read the migration guide; test on all supported platforms before merging |

## Transitive Dependency Review

- When a direct dependency update changes the transitive tree, **review the diff** in `pubspec.lock`.
- Flag any new transitive dependency that introduces native code, changes license, or pulls in an unusually large sub-tree.
- Use `dart pub outdated` to identify version skew across the monorepo.

## Semantic Versioning Strategy

- All workspace packages follow **semver** (`MAJOR.MINOR.PATCH`).
- Treat `pubspec.yaml` version constraints as **caret syntax** (`^x.y.z`) by default.
- Pin exact versions only when a known regression exists in a newer release.
- Never use `any` as a version constraint.

## Package Size Considerations

- Monitor the contribution of each dependency to final APK/IPA size using `--analyze-size`.
- Prefer tree-shakable, modular packages over monolithic ones.
- If a package adds > 500 KB to the release binary and only a small portion is used, consider extracting just the needed code (respecting its license).
