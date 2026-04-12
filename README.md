# EddyScout

PNW paddling companion (Flutter). This repo includes a Mapbox map with Portland-area launch pins.

## Mapbox access token

The map needs a [Mapbox public access token](https://account.mapbox.com/access-tokens/). Do not commit tokens to git.

Run on a device or simulator (the Mapbox Flutter SDK targets Android and iOS, not web):

```bash
flutter run --dart-define=ACCESS_TOKEN=YOUR_PUBLIC_TOKEN
```

Release builds:

```bash
flutter build apk --dart-define=ACCESS_TOKEN=YOUR_PUBLIC_TOKEN
```

### VS Code

Set environment variable `MAPBOX_ACCESS_TOKEN` in your shell or OS, then use the launch configuration **eddyscout (Mapbox token from env)** in [`.vscode/launch.json`](.vscode/launch.json). Use **eddyscout (no token — setup screen)** to open the in-app setup instructions.

Restrict your token by bundle ID / URL in the Mapbox dashboard before shipping.

## Getting Started

- [Flutter install](https://docs.flutter.dev/get-started/install)
- [Mapbox Maps Flutter](https://docs.mapbox.com/flutter/maps/guides/install/)
