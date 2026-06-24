# EddyScout developer commands. See AGENTS.md for details.
# Run `make` or `make help` for a compact target list.

.DEFAULT_GOAL := help

# ── Config ─────────────────────────────────────────────────────────
# Linux in CI; macOS on Darwin dev machines (integration_test/ requires a desktop target).
INTEGRATION_DEVICE := $(shell uname -s | grep -q Darwin && echo macos || echo linux)

.PHONY: help analyze bootstrap ci clean coverage coverage-check dev ensure-husky \
	format format-fix gen gen-check gen-reachability gen-reachability-check \
	gen-suggested-trips gen-suggested-trips-check \
	hydro-check hydro-fetch hydro-fetch-willamette hydro-fetch-columbia \
	hydro-fetch-camas-slough hydro-fetch-clackamas hydro-fetch-slough \
	hydro-fetch-tualatin hydro-fetch-sandy hydro-sync-fixtures \
	hydro-nhd-venv hydro-nhd-download hydro-nhd-convert hydro-nhd-validate \
	hydro-nhd-compare hydro-nhd-run \
	integration-test kill-emulator preflight run setup test

help: ## Help@show targets
	@printf 'EddyScout — make <target>\n\n'
	@grep -E '^[a-zA-Z0-9_-]+:.* ## ' Makefile \
		| grep -v '^help:' \
		| awk 'BEGIN {FS = ":.* ## "} \
		{ split($$2, p, "@"); \
		  if (p[1] != g) { if (g != "") print ""; printf "%s\n", p[1]; g = p[1] } \
		  printf "  %-20s %s\n", $$1, p[2] }'

# ── Setup ──────────────────────────────────────────────────────────

bootstrap: ## Setup@install deps, melos bootstrap
	./scripts/bootstrap.sh

ensure-husky: ## Setup@install git hooks (once per worktree)
	./scripts/ensure_husky.sh

setup: ## Setup@alias for bootstrap
	./scripts/bootstrap.sh

# ── Quality / CI ───────────────────────────────────────────────────

analyze: ## Quality@static analysis (all packages)
	dart run melos run analyze

ci: ## Quality@CI preflight (--ci)
	./scripts/preflight.sh --ci

coverage: ## Quality@tests with coverage
	dart run melos run coverage

coverage-check: coverage ## Quality@coverage + threshold check
	./scripts/check_coverage.sh

format: ## Quality@check formatting
	dart run melos run format

format-fix: ## Quality@fix formatting
	dart run melos run format:fix

gen: ## Quality@run code generation
	dart run melos run gen

gen-check: ## Quality@verify codegen is fresh
	dart run melos run gen:check

gen-reachability: ## Quality@generate launch reachability index JSON
	cd scripts && flutter pub get && dart run generate_launch_reachability_index.dart

gen-reachability-check: ## Quality@verify reachability index is fresh
	cd scripts && flutter pub get && dart run generate_launch_reachability_index.dart --check

gen-suggested-trips: ## Quality@generate launch suggested trips index JSON
	cd scripts && flutter pub get && dart run generate_launch_suggested_trips_index.dart

gen-suggested-trips-check: ## Quality@verify suggested trips index is fresh
	cd scripts && flutter pub get && dart run generate_launch_suggested_trips_index.dart --check

hydro-check: ## Quality@validate bundled hydro geometry (edges + confluences)
	./scripts/check_hydro_geometry.sh

hydro-fetch-columbia: ## Dev@Overpass import Columbia lower + gorge
	python3 scripts/overpass/fetch_columbia_waterway.py

hydro-fetch-willamette: ## Dev@Overpass import Willamette main stem
	python3 scripts/overpass/fetch_willamette_waterway.py

hydro-fetch-clackamas: ## Dev@Overpass import Clackamas
	python3 scripts/overpass/fetch_clackamas_waterway.py

hydro-fetch-camas-slough: ## Dev@Overpass import Camas Slough spur into columbia_lower
	python3 scripts/overpass/fetch_camas_slough_waterway.py

hydro-fetch-slough: ## Dev@Overpass import slough network
	python3 scripts/overpass/fetch_slough_waterway.py

hydro-fetch-tualatin: ## Dev@Overpass import Tualatin
	python3 scripts/overpass/fetch_tualatin_waterway.py

hydro-fetch-sandy: ## Dev@Overpass import Sandy River
	python3 scripts/overpass/fetch_sandy_waterway.py

hydro-fetch: ## Dev@run all Overpass fetchers (network required)
	./scripts/overpass/fetch_all_portland_hydro.sh

hydro-sync-fixtures: ## Dev@copy assets/hydro to test/fixtures
	./scripts/hydro/sync_fixtures.sh

hydro-nhd-venv: ## Hydro@create NHD Python venv (scripts/nhd/.venv)
	./scripts/nhd/ensure_venv.sh

hydro-nhd-download: hydro-nhd-venv ## Hydro@download NHD HU4 shapefiles (1708/1709)
	./scripts/nhd/download.sh

hydro-nhd-convert: hydro-nhd-venv ## Hydro@convert raw NHD shapefiles to GeoJSON
	. scripts/nhd/.venv/bin/activate && python3 scripts/nhd/convert.py

hydro-nhd-validate: hydro-nhd-venv ## Hydro@validate NHD output connectivity
	. scripts/nhd/.venv/bin/activate && python3 scripts/nhd/validate.py

hydro-nhd-compare: hydro-nhd-venv ## Hydro@compare NHD output vs bundled OSM
	./scripts/nhd/compare_bundled.sh

hydro-nhd-run: ## Hydro@download, convert, and validate NHD pipeline
	./scripts/nhd/run.sh

preflight: ## Quality@format, analyze, test, gen-check, coverage
	./scripts/preflight.sh

test: ## Quality@all package tests
	dart run melos run test

# ── Cleanup ────────────────────────────────────────────────────────

clean: ## Cleanup@remove build dirs and .dart_tool
	dart run melos run clean

# ── Local dev ──────────────────────────────────────────────────────

# Optional: RUN_TARGET=launch:Pixel_9 DEVICE_ID=emulator-5554 EMULATOR_ID=Pixel_9 DEV_INTERACTIVE=0
dev: ## Dev@bootstrap, .local.env, emulator, flutter run
	./scripts/dev.sh $(ARGS)

kill-emulator: ## Dev@stop emulators and orphan qemu (EMULATOR_SERIAL optional)
	./scripts/kill_emulator.sh

run: ## Dev@flutter run via apps/eddyscout (ARGS="-d …")
	$(MAKE) -C apps/eddyscout run ARGS="$(ARGS)"

# ── Integration tests ──────────────────────────────────────────────

integration-test: ## Integration@desktop integration_test/ (macos or linux)
	cd apps/eddyscout && flutter test integration_test/app_navigation_test.dart -d $(INTEGRATION_DEVICE)
	cd apps/eddyscout && flutter test integration_test/map_launch_detail_journey_test.dart -d $(INTEGRATION_DEVICE) \
		--dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
		--dart-define=INTEGRATION_MAP_STUB=true
