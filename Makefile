# EddyScout developer commands. See AGENTS.md for descriptions.

# ── Config ─────────────────────────────────────────────────────────
# Linux in CI; macOS on Darwin dev machines (integration_test/ requires a desktop target).
INTEGRATION_DEVICE := $(shell uname -s | grep -q Darwin && echo macos || echo linux)

.PHONY: analyze bootstrap ci clean coverage coverage-check dev ensure-husky \
	format format-fix gen gen-check integration-test kill-emulator preflight \
	run setup test

# ── Setup ──────────────────────────────────────────────────────────

bootstrap:
	./scripts/bootstrap.sh

ensure-husky:
	./scripts/ensure_husky.sh

setup:
	./scripts/bootstrap.sh

# ── Quality / CI ───────────────────────────────────────────────────

analyze:
	dart run melos run analyze

ci:
	./scripts/preflight.sh --ci

coverage:
	dart run melos run coverage

coverage-check: coverage
	./scripts/check_coverage.sh

format:
	dart run melos run format

format-fix:
	dart run melos run format:fix

gen:
	dart run melos run gen

gen-check:
	dart run melos run gen:check

preflight:
	./scripts/preflight.sh

test:
	dart run melos run test

# ── Cleanup ────────────────────────────────────────────────────────

clean:
	dart run melos run clean

# ── Local dev ──────────────────────────────────────────────────────

# Bootstrap worktree, link .local.env, start Android emulator if needed, flutter run.
# Optional: RUN_TARGET=launch:Pixel_9 RUN_TARGET=run:emulator-5554 DEVICE_ID=emulator-5554 EMULATOR_ID=Pixel_9 DEV_INTERACTIVE=0 AUTO_LAUNCH=0
dev:
	./scripts/dev.sh $(ARGS)

# Stop running Android emulators (adb emu kill). Optional: EMULATOR_SERIAL=emulator-5554
kill-emulator:
	./scripts/kill_emulator.sh

run:
	$(MAKE) -C apps/eddyscout run ARGS="$(ARGS)"

# ── Integration tests ──────────────────────────────────────────────

integration-test:
	cd apps/eddyscout && flutter test integration_test/app_navigation_test.dart -d $(INTEGRATION_DEVICE)
	cd apps/eddyscout && flutter test integration_test/map_launch_detail_journey_test.dart -d $(INTEGRATION_DEVICE) \
		--dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
		--dart-define=INTEGRATION_MAP_STUB=true
