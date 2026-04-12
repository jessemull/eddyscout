# EddyScout

PNW paddling companion (Flutter). Mapbox map with Portland-area launch pins.

## Local dev: Mapbox token

The app reads **`MAPBOX_ACCESS_TOKEN` only via `--dart-define`** (compile-time). Nothing is loaded from bundled `.env` files.

### Recommended: gitignored `.local.env` + script

1. Copy the template (once):

   ```bash
   cp env.example .local.env
   ```

2. Edit **`.local.env`** and set your [Mapbox public token](https://account.mapbox.com/access-tokens/):

   ```env
   MAPBOX_ACCESS_TOKEN=pk.your_token_here
   ```

3. Run (add **`-d emulator-5554`** or another device id if needed):

   ```bash
   ./scripts/run_android.sh
   ./scripts/run_android.sh -d emulator-5554
   ```

Or use **Make**:

```bash
make setup   # creates .local.env from env.example if missing
make run     # same as ./scripts/run_android.sh
```

**Never commit `.local.env`** (it is gitignored).

### Alternative: manual `flutter run`

```bash
flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

### VS Code / Cursor

Use **eddyscout (Mapbox token from env)** in [`.vscode/launch.json`](.vscode/launch.json) with `MAPBOX_ACCESS_TOKEN` set in your environment, or run **`./scripts/run_android.sh`** from a terminal.

Mapbox Flutter targets **Android and iOS**, not web.

## Getting Started

- [Flutter install](https://docs.flutter.dev/get-started/install)
- [Mapbox Maps Flutter](https://docs.mapbox.com/flutter/maps/guides/install/)
