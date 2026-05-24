.PHONY: bootstrap analyze format test coverage gen gen-check clean preflight ci setup

bootstrap:
	./scripts/bootstrap.sh

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
