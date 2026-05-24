# Feature Development

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when creating a new feature end-to-end: scaffold, domain, data, presentation, tests, and PR.

## References

- `docs/ARCHITECTURE.md` — package structure, layer rules
- `docs/GOVERNANCE.md` — PR process and review policy
- `docs/TESTING.md` — coverage requirements

## Checklist

### 1. Read Context

- [ ] Read `CONTEXT.md` (loading order, constraints, quality gates)
- [ ] Read `AGENTS.md` (development rules, architecture, coding standards)
- [ ] Read `docs/ARCHITECTURE.md` (package boundaries, dependency graph)

### 2. Scaffold the Feature Package

- [ ] Copy `_TEMPLATE/` to `packages/<feature_name>/` or `apps/eddyscout/lib/features/<feature>/`
- [ ] Rename references in `pubspec.yaml`, barrel exports, and directory names
- [ ] Register the package in `melos.yaml` if it is a new top-level package
- [ ] Verify directory structure:
  ```
  feature/
  ├── domain/       # entities, repo contracts, use cases
  ├── data/         # repo implementations, data sources, DTOs
  └── presentation/ # widgets, screens, providers
  ```

### 3. Implement Domain Layer (first)

- [ ] Define entities with `@freezed`
- [ ] Define repository contracts (abstract classes)
- [ ] Create use cases that depend only on domain contracts
- [ ] No imports from `data/` or `presentation/`

### 4. Implement Data Layer

- [ ] Implement repository contracts from domain
- [ ] Create DTOs with `@JsonSerializable` / `@freezed`
- [ ] Add data sources (API, local, etc.)
- [ ] Imports only from `domain/` — never from `presentation/`

### 5. Implement Presentation Layer

- [ ] Create Riverpod providers (use `@riverpod` codegen where applicable)
- [ ] Build widgets/screens — no business logic in `build()`
- [ ] Handle all `AsyncValue` states: loading, error, data
- [ ] Use `const` constructors wherever possible
- [ ] Add typed `GoRoute` and register in router config

### 6. Add Tests

- [ ] Unit tests for domain use cases and data repositories
- [ ] Widget tests for screens (mock providers with `ProviderScope.overrides`)
- [ ] Follow `docs/TESTING.md` for naming and coverage thresholds

### 7. Validate and PR

- [ ] Run `make gen` to regenerate code
- [ ] Run `make preflight` — all gates must pass
- [ ] Commit with Conventional Commit format: `feat(<scope>): <description>`
- [ ] Open PR following `docs/GOVERNANCE.md`
