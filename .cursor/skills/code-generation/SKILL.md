---
name: code-generation
description: >-
  Manage build_runner code generation for EddyScout: freezed, json_serializable,
  riverpod_generator, go_router_builder. Use when adding/modifying annotated
  models, providers, or routes.
---

# Code Generation

Read the following before performing any code generation work:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/CODEGEN.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`

For localization generation (`flutter gen-l10n`), see `docs/LOCALIZATION.md` and the `localization` skill instead.

Code generation is a critical repository system.

Generated code integrity is mandatory.

Incorrect codegen workflows can:
- corrupt builds
- create stale runtime behavior
- break serialization
- break Riverpod providers
- break navigation
- introduce hidden analyzer issues
- create CI drift
- introduce non-deterministic behavior

Generated code must always be deterministic, reproducible, and machine-generated.

---

# When to Use

Use this skill when working with:

- `freezed`
- `json_serializable`
- `riverpod_generator`
- `go_router_builder`
- `build_runner`
- generated providers
- generated routes
- generated models

This skill does NOT cover:
- Localization generation (`flutter gen-l10n`) — use `localization` skill
- API client generation — not currently used in this repository
- Dependency injection generation — Riverpod is the DI container (see `riverpod-usage` skill)

This skill is required whenever:
- adding annotations
- modifying annotated classes/functions
- renaming generated types
- changing provider signatures
- changing routes
- changing serialization
- changing immutable models
- changing generated unions/sealed classes
- changing generated localization resources

---

# Core Principles

## Generated Code Is Read-Only

Generated files must NEVER be manually edited.

If generated output is incorrect:
1. fix the source definition
2. regenerate
3. verify analyzer/test/build integrity

Never patch generated files manually.

---

## Source Files Are The Source of Truth

Annotations and source declarations are authoritative.

Generated files are implementation artifacts.

---

## Generated Code Must Remain Deterministic

Code generation output must:
- be reproducible
- produce clean diffs
- avoid non-deterministic ordering
- avoid stale outputs
- remain analyzer-clean

---

# Approved Code Generation Systems

| System | Purpose |
|---|---|
| `freezed` | immutable models, unions, sealed classes |
| `json_serializable` | JSON serialization |
| `riverpod_generator` | provider generation |
| `go_router_builder` | typed routes |
| `build_runner` | generation orchestration |

Only these generators are approved per `docs/CODEGEN.md`. Adding a new generator requires updating that document and the approved dependency list in `docs/DEPENDENCIES.md`.

---

# Annotation Reference

| Annotation | Package | Generates |
|---|---|---|
| `@freezed` | `freezed` | immutable models, unions, copyWith, equality |
| `@JsonSerializable()` | `json_serializable` | JSON serialization |
| `@riverpod` | `riverpod_generator` | typed Riverpod providers |
| `@TypedGoRoute` | `go_router_builder` | typed navigation helpers |

---

# 1. Annotation Review

## Annotation Correctness

- [ ] Correct annotation selected
- [ ] Annotation usage follows repository conventions
- [ ] Annotation scope minimized appropriately
- [ ] Generated type ownership clear

## Imports

- [ ] Correct annotation imports added
- [ ] Unused imports removed
- [ ] Import ordering follows repository rules

## Part Directives

- [ ] Correct `part` directives added
- [ ] File names match conventions exactly
- [ ] No duplicate part declarations
- [ ] No stale part declarations remain

Examples:

```dart
part 'user.freezed.dart';
part 'user.g.dart';
```

---

# 2. File Organization Review

## Source File Structure

- [ ] Source file organized clearly
- [ ] Generated code separated cleanly
- [ ] Annotated models grouped logically
- [ ] Feature ownership respected

## Naming Conventions

- [ ] File names consistent
- [ ] Generated output names predictable
- [ ] Provider names follow conventions
- [ ] Route names follow conventions

---

# 3. Freezed Review

## Model Design

- [ ] Models immutable
- [ ] Fields typed correctly
- [ ] Nullability intentional
- [ ] Defaults handled correctly

## Union / Sealed Classes

- [ ] States modeled explicitly
- [ ] Exhaustive state handling possible
- [ ] Invalid states avoided
- [ ] Union naming clear

## Serialization

- [ ] Serialization compatibility verified
- [ ] Nested models serializable
- [ ] Date handling consistent
- [ ] Enum serialization explicit where needed

## Performance

- [ ] Large nested model graphs justified
- [ ] Unnecessary model duplication avoided
- [ ] Deep copy complexity acceptable

---

# 4. Riverpod Generator Review

## Provider Architecture

- [ ] Correct provider type chosen
- [ ] Provider ownership clear
- [ ] Provider lifecycle intentional
- [ ] Async providers justified

## Provider Safety

- [ ] `autoDispose` considered intentionally
- [ ] Provider families scoped correctly
- [ ] Circular provider dependencies avoided
- [ ] Provider rebuild scope minimized

## Generated Provider Integrity

- [ ] Generated provider names correct
- [ ] Ref types correct
- [ ] Provider annotations minimal and clear
- [ ] No duplicated provider responsibilities

---

# 5. JSON Serialization Review

## Serialization Integrity

- [ ] `fromJson` and `toJson` generated correctly
- [ ] Required fields validated
- [ ] Optional fields intentional
- [ ] Nested serialization valid

## API Compatibility

- [ ] API contract preserved
- [ ] Backward compatibility considered
- [ ] Unknown field handling intentional
- [ ] Enum serialization stable

## Safety

- [ ] Dynamic typing minimized
- [ ] Unsafe casts avoided
- [ ] Serialization edge cases considered

---

# 6. Typed Routing Review

## Route Design

- [ ] Typed routes used correctly
- [ ] Route ownership respected
- [ ] Route naming clear
- [ ] Deep link compatibility preserved

## Navigation Safety

- [ ] Required parameters validated
- [ ] Optional parameters intentional
- [ ] Invalid navigation states avoided
- [ ] Route transitions safe

---

# 7. Build Runner Execution

## Required Commands

Run generation from repository root whenever possible.

Primary command:

```bash
make gen
```

Single package:

```bash
cd packages/<package-name>
dart run build_runner build --delete-conflicting-outputs
```

Watch mode:

```bash
dart run build_runner watch
```

---

# 8. Code Generation Verification

## Generated Files

- [ ] Expected generated files created
- [ ] No stale generated artifacts remain
- [ ] Generated files formatted correctly
- [ ] Generated output deterministic

## Analyzer Validation

- [ ] `dart analyze` passes
- [ ] No generated analyzer warnings
- [ ] No missing generated symbols
- [ ] No stale imports

## Build Validation

- [ ] App builds successfully
- [ ] Tests pass after regeneration
- [ ] CI codegen verification passes

---

# 9. Generated File Governance

## NEVER

- [ ] Never manually edit generated files
- [ ] Never suppress generator errors improperly
- [ ] Never partially regenerate repository state
- [ ] Never commit stale generated artifacts
- [ ] Never bypass generation checks

## MUST

- [ ] Regenerate after annotation changes
- [ ] Commit generated files with source changes
- [ ] Keep generated files analyzer-clean
- [ ] Keep generation reproducible

---

# 10. CI/CD Validation

## Required Validation

- [ ] `make gen-check`
- [ ] `make preflight`
- [ ] `dart analyze`
- [ ] `flutter test`

## CI Gates

- [ ] No codegen drift
- [ ] No stale generated files
- [ ] No analyzer violations
- [ ] No formatting violations

---

# 11. Common Code Generation Failure Modes

## MUST NOT

- [ ] Edit generated files manually
- [ ] Forget required `part` declarations
- [ ] Commit stale generated artifacts
- [ ] Ignore generator warnings
- [ ] Create circular generated dependencies
- [ ] Generate conflicting provider names
- [ ] Create serialization ambiguity

## SHOULD AVOID

- [ ] Overusing generated abstractions
- [ ] Deeply nested generated models
- [ ] Excessive provider generation
- [ ] Large monolithic generated files
- [ ] Hidden magic behavior

---

# 12. AI-Assisted Development Checks

## AI Safety

- [ ] Annotation usage verified against repository conventions
- [ ] Generated APIs actually exist
- [ ] Generator package APIs verified
- [ ] No hallucinated annotations/packages used

## Consistency

- [ ] Matches repository naming conventions
- [ ] Matches repository architecture
- [ ] Matches repository provider patterns
- [ ] Matches repository serialization patterns

---

# Review Output Format

Structure findings as:

## MUST
Blocking code generation issues.

## SHOULD
Important code generation improvements.

## NICE TO HAVE
Optional code generation improvements.

Each finding should include:
- issue description
- severity
- affected file(s)
- generator/tool impacted
- suggested fix