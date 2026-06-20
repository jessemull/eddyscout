import 'dart:io';

Directory _repoRoot() {
  var dir = Directory.current;
  while (true) {
    final hydroDir = Directory('${dir.path}/apps/eddyscout/assets/hydro');
    if (hydroDir.existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }
  throw StateError(
    'Could not locate apps/eddyscout/assets/hydro from ${Directory.current.path}',
  );
}

/// Reads bundled hydro GeoJSON from the app shell (single source of truth).
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
    '${_repoRoot().path}/apps/eddyscout/assets/hydro/$fileName',
  );
  return file.readAsString();
}

/// All bundled waterway GeoJSON documents from the app asset bundle.
Future<List<String>> readBundledHydroGeoJsonDocuments() async {
  const paths = [
    'assets/hydro/willamette_waterway.geojson',
    'assets/hydro/columbia_lower_waterway.geojson',
    'assets/hydro/columbia_gorge_waterway.geojson',
    'assets/hydro/clackamas_waterway.geojson',
    'assets/hydro/slough_waterway.geojson',
    'assets/hydro/tualatin_waterway.geojson',
    'assets/hydro/sandy_waterway.geojson',
  ];
  return [for (final path in paths) await readBundledHydroAsset(path)];
}
