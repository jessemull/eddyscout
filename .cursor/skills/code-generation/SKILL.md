# Code Generation

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when working with code generation annotations (`freezed`, `json_serializable`, `riverpod_generator`, `go_router_builder`).

## References

- `docs/CODEGEN.md` — codegen setup, commands, and troubleshooting

## Annotations Reference

| Annotation | Package | Generates |
|-----------|---------|-----------|
| `@freezed` | `freezed` | Immutable data classes, `copyWith`, `==`, `toString` |
| `@JsonSerializable()` | `json_serializable` | `fromJson` / `toJson` methods |
| `@riverpod` | `riverpod_generator` | Provider declarations |
| `@TypedGoRoute` | `go_router_builder` | Type-safe route helpers |

## Checklist

### 1. Add Annotations

- [ ] Add the correct annotation to the class or function
- [ ] Add the `part` directive: `part '<filename>.g.dart';` or `part '<filename>.freezed.dart';`
- [ ] Import the annotation package in the file

### 2. Run Code Generation

```bash
make gen
```

- [ ] Run `make gen` from the repo root (uses `build_runner` via melos)
- [ ] For a single package: `cd packages/<name> && dart run build_runner build --delete-conflicting-outputs`
- [ ] Watch mode during development: `dart run build_runner watch`

### 3. Verify Output

- [ ] Check that generated files (`*.g.dart`, `*.freezed.dart`) are created
- [ ] Verify no build_runner errors in the output
- [ ] Run `dart analyze` to confirm generated code has no issues

### 4. Never Edit Generated Files

- [ ] **Never** manually modify `*.g.dart`, `*.freezed.dart`, or `*.gr.dart`
- [ ] If generated output is wrong, fix the source annotation and regenerate
- [ ] If a generated file must be hand-edited, escalate to a human maintainer

### 5. Commit Generated Files

- [ ] Generated files are committed to the repository (not gitignored)
- [ ] Run `make gen-check` to verify codegen is fresh before committing
- [ ] Commit generated files in the same commit as their source changes

### 6. Validate

- [ ] Run `make preflight`
- [ ] Verify CI passes `gen-check` gate
