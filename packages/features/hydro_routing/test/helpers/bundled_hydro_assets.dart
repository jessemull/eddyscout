import 'dart:io';

/// Reads bundled hydro GeoJSON from the app shell (single source of truth).
///
/// [assetPath] must be under `assets/hydro/`, e.g.
/// `assets/hydro/willamette_waterway.geojson`.
Future<String> readBundledHydroAsset(String assetPath) async {
  if (!assetPath.startsWith('assets/hydro/')) {
    throw ArgumentError.value(
      assetPath,
      'assetPath',
      'Expected path under assets/hydro/',
    );
  }
  final fileName = assetPath.replaceFirst('assets/hydro/', '');
  final file = File(
    '${Directory.current.path}/../../../apps/eddyscout/assets/hydro/$fileName',
  );
  return file.readAsString();
}

/// Loads all bundled hydro GeoJSON documents from the app asset bundle.
Future<List<String>> readBundledHydroGeoJsonDocuments() async {
  return [
    await readBundledHydroAsset('assets/hydro/willamette_waterway.geojson'),
    await readBundledHydroAsset('assets/hydro/columbia_lower_waterway.geojson'),
    await readBundledHydroAsset(
      'assets/hydro/columbia_gorge_waterway.geojson',
    ),
  ];
}

/// Loads curated confluence bridge JSON from the app asset bundle.
Future<String> readBundledConfluenceBridgesJson() =>
    readBundledHydroAsset('assets/hydro/confluence_bridges.json');
