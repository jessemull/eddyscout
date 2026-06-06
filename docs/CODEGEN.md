# EddyScout — Code Generation Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when creating or modifying models, providers, routes, or any file that participates in code generation; when running `build_runner`; when reviewing generated file diffs; or when troubleshooting codegen issues.

---

## Sole Codegen Runner

**`build_runner`** is the only code generation runner permitted in this project. Do not introduce `source_gen` scripts, custom builders outside `build.yaml`, or alternative generation tools without updating this document.

Run generation via melos:

```bash
melos run build_runner    # all packages
```

Or per-package:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Governed Generators

| Generator | Annotation / trigger | Output suffix |
|-----------|---------------------|---------------|
| **freezed** | `@freezed`, `@Freezed()` | `.freezed.dart` |
| **json_serializable** | `@JsonSerializable()` | `.g.dart` |
| **riverpod_generator** | `@riverpod`, `@Riverpod()` | `.g.dart` |
| **go_router_builder** | `@TypedGoRoute` | `.g.dart` |

Only these generators are approved. Adding a new generator requires updating this document and the approved dependency list in `DEPENDENCIES.md`.

## When Generation Must Run

Re-run `build_runner` **immediately** after any of the following changes:

- Adding, removing, or modifying a `@freezed` model class
- Changing `@JsonSerializable` fields, `@JsonKey` annotations, or `toJson`/`fromJson` signatures
- Adding, removing, or modifying a `@riverpod` annotated provider
- Changing route definitions annotated with `@TypedGoRoute`
- Modifying `build.yaml` configuration

**Do not** commit source changes without also committing the corresponding regenerated output.

## Generated File Ownership

- Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) are **machine-owned**.
- **Never** manually edit a generated file. Any manual edit will be silently overwritten on the next build.
- If the generated output is wrong, fix the **source annotation or configuration**, then regenerate.

## Commit Rules

Generated files **are committed** to version control.

Rationale:
- Ensures `flutter analyze` and CI pass without requiring a build step before analysis.
- Makes PR diffs reviewable — reviewers can verify generated output matches source changes.
- Reduces CI build time (no mandatory generation step for every check).

## Forbidden Manual Edits

The following file patterns must **never** be manually edited:

| Pattern | Generator |
|---------|-----------|
| `*.g.dart` | json_serializable, riverpod_generator, go_router_builder |
| `*.freezed.dart` | freezed |
| `*.gr.dart` | go_router_builder (if configured with this suffix) |

Enforce this via PR review. If a diff touches only generated files without a corresponding source change, reject it.

## Generation Verification in CI (Codegen Drift Check)

CI runs a **codegen drift check** to ensure committed generated files match what `build_runner` would produce:

```yaml
# Simplified CI step
- name: Codegen drift check
  run: |
    dart run build_runner build --delete-conflicting-outputs
    git diff --exit-code
```

If `git diff` finds changes, the check **fails** — the developer forgot to regenerate before committing. This is a **blocking** CI check.

## Troubleshooting Guide

### `build_runner` fails with conflicting outputs

```bash
dart run build_runner build --delete-conflicting-outputs
```

The `--delete-conflicting-outputs` flag removes stale generated files before rebuilding.

### Stale `.g.dart` / `.freezed.dart` files after branch switch

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Part directive errors

Ensure every file using codegen has the correct `part` directive:

```dart
part 'my_model.freezed.dart';  // for freezed
part 'my_model.g.dart';        // for json_serializable / riverpod_generator
```

The part file name must exactly match the source file name with the appropriate suffix.

### Circular dependency errors

`build_runner` cannot resolve circular imports. Break cycles by extracting shared types into a separate file that both sides import.

### Generation is slow

- Use `build_runner watch` during active development for incremental rebuilds.
- Ensure `build.yaml` has appropriate `generate_for` filters to limit scope.
- Split large packages if generation time exceeds 30 seconds.

### CI drift check fails but local build passes

- Ensure your local Dart/Flutter SDK version matches CI (check `.tool-versions`).
- Run `dart pub get` before `build_runner` to ensure dependency alignment.
- Verify you committed from a clean generation state, not a partial one.

## Riverpod codegen in `eddyscout_conditions`

The conditions feature package is the first production consumer of `@riverpod` codegen.

### Setup

1. **`riverpod_annotation`** in `dependencies`; **`riverpod_generator`** in `dev_dependencies` ([`packages/features/conditions/pubspec.yaml`](../packages/features/conditions/pubspec.yaml)).
2. Register provider source files under `riverpod_generator.generate_for.include` in [`packages/features/conditions/build.yaml`](../packages/features/conditions/build.yaml) (alongside existing `freezed` / `json_serializable` scopes).
3. Annotate providers with `@riverpod` or `@Riverpod(...)`; add `part '<file>.g.dart';` to each source file.
4. Run `make gen` from the repo root (or `dart run build_runner build` in the package).

### Retry on future providers

`@Riverpod` is a `const` constructor — do **not** pass inline lambdas to `retry:`. Use a top-level function tear-off:

```dart
Duration? _disableProviderRetry(int retryCount, Object error) => null;

@Riverpod(retry: _disableProviderRetry)
Future<ConditionsSnapshot> conditionsSnapshot(Ref ref, LaunchPoint launch) async { … }
```

### Pilot reference

The refresh-token pilot at [`docs/examples/condition_reports_refresh_token_provider.riverpod_pilot.dart`](examples/condition_reports_refresh_token_provider.riverpod_pilot.dart) is implemented in production at [`packages/features/conditions/lib/src/domain/condition_reports_refresh_token_provider.dart`](../packages/features/conditions/lib/src/domain/condition_reports_refresh_token_provider.dart).

### Prerequisites (resolved)

- Workspace-wide `flutter_riverpod` 3.x (merged PR #19).
- `riverpod_generator` 4.x works with the workspace `source_gen: 4.2.0` override.

### Next packages

App-shell providers (`apps/eddyscout/lib/preferences/`, map session/planning, router) remain manual until a follow-up migration PR.
