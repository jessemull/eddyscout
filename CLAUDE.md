# Claude Agent Instructions — EddyScout

Before making any changes to this repository:

1. Read `CONTEXT.md` — mandatory loading order, precedence chain, quality gates
2. Read `AGENTS.md` — complete development rules and constraints
3. Read task-specific docs from `docs/` as listed in CONTEXT.md

Do NOT duplicate governance from AGENTS.md or docs/ here. This file exists only as an entry point redirect.

## Quick Reference

- Bootstrap: `./scripts/bootstrap.sh`
- Preflight: `make preflight`
- Test: `make test`
- Analyze: `make analyze`
- Format: `make format-fix`
- Codegen: `make gen`
