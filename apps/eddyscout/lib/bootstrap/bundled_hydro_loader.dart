import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Loads all bundled hydro GeoJSON documents from the app asset bundle.
Future<List<String>> loadBundledHydroGeoJsonFromAssets() async {
  final docs = <String>[
    for (final path in bundledHydroGeoJsonAssetPaths)
      await rootBundle.loadString(path),
  ];
  if (kDebugMode) {
    assertBundledHydroGeoJsonLoaded(docs);
  }
  return docs;
}

/// Loads precomputed unified hydro graph binary when bundled.
Future<Uint8List?> loadBundledHydroGraphBinaryFromAssets() async {
  try {
    final data = await rootBundle.load(bundledHydroGraphBinaryAssetPath);
    return data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
  } on Object {
    return null;
  }
}

/// Fails fast in debug when the bundle is incomplete (needs lower Columbia).
void assertBundledHydroGeoJsonLoaded(List<String> docs) {
  final expected = bundledHydroGeoJsonAssetPaths.length;
  if (docs.length != expected) {
    throw StateError(
      'Expected $expected bundled hydro GeoJSON assets but loaded '
      '${docs.length}. Run flutter clean, then rebuild from the '
      'feat/overpass-waterway-import worktree.',
    );
  }
  final hasLowerColumbia = docs.any(
    (doc) =>
        doc.contains('columbia_lower') ||
        doc.contains('columbia_lower_waterway'),
  );
  if (!hasLowerColumbia) {
    throw StateError(
      'Bundled hydro is missing columbia_lower_waterway geometry. '
      'Cross-system routing (Willamette ↔ Columbia) requires the full '
      'hydro bundle.',
    );
  }
}
