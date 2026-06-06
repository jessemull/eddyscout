.PHONY: bootstrap ensure-husky analyze format test coverage coverage-check gen gen-check clean preflight ci setup run integration-test

bootstrap:
	./scripts/bootstrap.sh

ensure-husky:
	./scripts/ensure_husky.sh

analyze:
	dart run melos run analyze

format:
	dart run melos run format

format-fix:
	dart run melos run format:fix

test:
	dart run melos run test

coverage:
	dart run melos run coverage

coverage-check: coverage
	./scripts/check_coverage.sh

gen:
	dart run melos run gen

gen-check:
	dart run melos run gen:check

clean:
	dart run melos run clean

preflight:
	./scripts/preflight.sh

ci:
	./scripts/preflight.sh --ci

setup:
	./scripts/bootstrap.sh

run:
	$(MAKE) -C apps/eddyscout run ARGS="$(ARGS)"

# Linux in CI; macOS on Darwin dev machines (integration_test/ requires a desktop target).
INTEGRATION_DEVICE := $(shell uname -s | grep -q Darwin && echo macos || echo linux)

integration-test:
	cd apps/eddyscout && flutter test integration_test/app_navigation_test.dart -d $(INTEGRATION_DEVICE)
	cd apps/eddyscout && flutter test integration_test/map_launch_detail_journey_test.dart -d $(INTEGRATION_DEVICE) \
		--dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
		--dart-define=INTEGRATION_MAP_STUB=true
