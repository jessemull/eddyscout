.PHONY: run setup

# First-time: create .local.env from template (does not overwrite).
setup:
	@if [ ! -f .local.env ]; then cp env.example .local.env && echo "Created .local.env — add MAPBOX_ACCESS_TOKEN=pk...."; else echo ".local.env already exists — edit MAPBOX_ACCESS_TOKEN there."; fi

# Run on a connected device/emulator (pass -d emulator-5554 if needed).
run:
	./scripts/run_android.sh
