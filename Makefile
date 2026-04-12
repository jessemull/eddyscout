.PHONY: run setup

# First-time: create .local.env from template (does not overwrite).
setup:
	@if [ ! -f .local.env ]; then cp env.example .local.env && echo "Created .local.env — set MAPBOX_ACCESS_TOKEN; optionally uncomment USE_FIREBASE=true."; else echo ".local.env already exists — edit MAPBOX_ACCESS_TOKEN (and USE_FIREBASE) there."; fi

# Run on a connected device/emulator (pass -d emulator-5554 if needed).
# Sources .local.env: MAPBOX_ACCESS_TOKEN (required); USE_FIREBASE=true optional → --dart-define.
run:
	./scripts/run_android.sh
