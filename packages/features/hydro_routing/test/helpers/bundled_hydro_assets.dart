import 'dart:io';
import 'dart:typed_data';

import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';

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
    '${_repoRoot().path}/apps/eddyscout/assets/hydro/$fileName',
  );
  return file.readAsString();
}

/// All bundled waterway GeoJSON documents from the app asset bundle.
Future<List<String>> readBundledHydroGeoJsonDocuments() async {
  return [
    for (final path in bundledHydroGeoJsonAssetPaths)
      await readBundledHydroAsset(path),
  ];
}

/// Loads curated confluence bridge JSON from the app asset bundle.
Future<String> readBundledConfluenceBridgesJson() =>
    readBundledHydroAsset(bundledConfluenceBridgesAssetPath);

/// Loads precomputed unified hydro graph binary from the app asset bundle.
Future<Uint8List> readBundledHydroGraphBinary() async {
  final file = File(
    '${_repoRoot().path}/apps/eddyscout/assets/data/unified_hydro_graph.bin',
  );
  return file.readAsBytes();
}
