# Feature Package Template

Each feature lives in `packages/features/<feature_name>/`.

## Required Structure

```
feature_name/
├── pubspec.yaml              # resolution: workspace
├── analysis_options.yaml     # include: ../../../tooling/analysis_options.package.yaml
├── README.md
├── lib/
│   ├── feature_name.dart     # Barrel file — public API only
│   └── src/
│       ├── presentation/     # Widgets, pages, view models
│       │   ├── pages/
│       │   ├── widgets/
│       │   └── providers/    # Riverpod providers for this feature
│       ├── domain/           # Business logic, entities, use cases
│       │   ├── entities/
│       │   ├── repositories/ # Abstract repository interfaces
│       │   └── use_cases/
│       └── data/             # Data sources, DTOs, repository implementations
│           ├── data_sources/
│           ├── dtos/
│           └── repositories/
└── test/
    ├── presentation/
    ├── domain/
    └── data/
```

## Dependency Rules

- `presentation/` → may import `domain/` (NEVER `data/`)
- `domain/` → may import ONLY `eddyscout_core` (NEVER `data/` or `presentation/`)
- `data/` → may import `domain/` (for repository interfaces and entities)
- Features MUST NOT import from other features directly

## Naming Conventions

- Package name: `eddyscout_<feature_name>` (snake_case)
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: `camelCaseProvider`

## Checklist for New Features

- [ ] Package created with correct structure
- [ ] `resolution: workspace` in pubspec.yaml
- [ ] Added to root `pubspec.yaml` workspace list
- [ ] Barrel file exports only public API
- [ ] No cross-feature imports
- [ ] Tests mirror lib/ structure
- [ ] README references relevant docs/
