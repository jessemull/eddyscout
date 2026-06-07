# EddyScout

PNW paddling companion — Mapbox map with Portland-area launch pins.

## Quick Start

```bash
# One command (new worktrees: bootstraps packages, links .local.env, starts emulator, runs app)
make dev

# First time only: set your Mapbox token in your main clone's .local.env, or:
cd apps/eddyscout && cp env.example .local.env
# Edit MAPBOX_ACCESS_TOKEN, then make dev again.

# Optional: point all worktrees at canonical secrets (auto-linked from sibling worktrees by default)
export EDDYSCOUT_LOCAL_ENV=~/Development/eddyscout/apps/eddyscout/.local.env
export EDDYSCOUT_GOOGLE_SERVICES=~/Development/eddyscout/apps/eddyscout/android/app/google-services.json

# Optional: skip pickers — EMULATOR_ID=Pixel_7 DEVICE_ID=emulator-5554 DEV_INTERACTIVE=0
```

Manual setup: `./scripts/bootstrap.sh`, then `make run` (emulator must already be running).

## Repository Structure

```
eddyscout/
├── apps/eddyscout/          # Main Flutter application
├── packages/
│   ├── core/                # Shared types, Result, AppFailure
│   ├── design_system/       # Material 3 theme, tokens
│   ├── networking/          # Dio networking layer
│   ├── persistence/         # Local storage abstractions
│   ├── analytics/           # Analytics interface
│   ├── routing/             # go_router navigation
│   ├── localization/        # ARB-based translations
│   └── features/            # Feature packages (template)
├── tooling/                 # Shared analysis, build, coverage config
├── docs/                    # Governance & engineering documentation
├── scripts/                 # Automation scripts
└── .github/                 # CI workflows
```

## AI Agents

Read `CONTEXT.md` before making any changes. It provides mandatory loading order, source-of-truth precedence, and quality gates.

- **Cursor**: Rules auto-loaded from `.cursor/rules/`
- **Claude Code**: Read `CLAUDE.md`
- **Gemini CLI**: Read `GEMINI.md`

## Development

| Command | Description |
|---------|-------------|
| `make bootstrap` | Initial setup (includes husky hooks) |
| `make ensure-husky` | Install git hooks in a new worktree |
| `make analyze` | Static analysis |
| `make format` | Check formatting |
| `make format-fix` | Fix formatting |
| `make test` | Run all tests |
| `make coverage` | Test with coverage |
| `make gen` | Run code generation |
| `make gen-check` | Verify codegen is fresh |
| `make preflight` | Full checks + coverage (optional; `git push` runs most gates) |
| `make ci` | CI-grade validation |
| `make clean` | Clean all packages |
| `make dev` | Bootstrap worktree + link secrets + start Android emulator + `flutter run` |
| `make run` | Run app on device/emulator (needs `apps/eddyscout/.local.env`) |

## Documentation

See `docs/` for comprehensive governance:

- [Architecture](docs/ARCHITECTURE.md)
- [Contributing](docs/CONTRIBUTING.md)
- [Governance](docs/GOVERNANCE.md)
- [Review](docs/REVIEW.md)
- [Testing](docs/TESTING.md)
- [Security](docs/SECURITY.md)

## Tech Stack

- Flutter stable / Dart 3+
- Material 3
- Riverpod (state management)
- go_router (navigation)
- dio (networking)
- freezed + json_serializable (models)
- drift (structured storage)
- melos (monorepo)
- very_good_analysis (linting)
- GitHub Actions (CI)
