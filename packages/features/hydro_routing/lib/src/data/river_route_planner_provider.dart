import 'dart:typed_data';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_exception.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_mapper.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_debug_log.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'river_route_planner_provider.g.dart';

/// Loads bundled hydro GeoJSON from the app asset bundle.
typedef HydroGeoJsonLoader = Future<List<String>> Function();

/// Loads curated confluence bridge JSON, or null when none are bundled.
typedef HydroConfluenceBridgesLoader = Future<String?> Function();

/// Loads precomputed hydro graph binary, or null to force GeoJSON build.
typedef HydroGraphBinaryLoader = Future<Uint8List?> Function();

/// Override in the app shell with rootBundle.loadString for hydro assets.
@Riverpod(keepAlive: true)
HydroGeoJsonLoader hydroGeoJsonLoader(Ref ref) {
  throw UnimplementedError(
    'Override hydroGeoJsonLoaderProvider in ProviderScope (app shell).',
  );
}

/// Optional confluence bridge JSON for cross-system routing.
@Riverpod(keepAlive: true)
HydroConfluenceBridgesLoader hydroConfluenceBridgesLoader(Ref ref) {
  return () async => null;
}

/// Optional precomputed graph binary for faster cold start.
@Riverpod(keepAlive: true)
HydroGraphBinaryLoader hydroGraphBinaryLoader(Ref ref) {
  return () async => null;
}

/// Bundled hydro graphs for river routing between launches.
@Riverpod(keepAlive: true, retry: disableProviderRetry)
Future<RiverRoutePlanner> riverRoutePlanner(Ref ref) async {
  final loadBinary = ref.read(hydroGraphBinaryLoaderProvider);
  try {
    final bytes = await loadBinary();
    if (bytes != null && bytes.isNotEmpty) {
      return RiverRoutePlanner.fromBinary(bytes);
    }
  } on FormatException catch (e) {
    hydroDebugLog('hydro graph binary decode failed, falling back: $e');
  } on Object catch (e) {
    hydroDebugLog('hydro graph binary load failed, falling back: $e');
  }

  final load = ref.read(hydroGeoJsonLoaderProvider);
  final loadBridges = ref.read(hydroConfluenceBridgesLoaderProvider);
  try {
    final rawDocs = await load();
    final bridgesJson = await loadBridges();
    return RiverRoutePlanner.fromGeoJsonDocuments(
      rawDocs,
      confluenceBridgesJson: bridgesJson,
    );
  } on Object catch (e, st) {
    throw HydroAppFailureException(mapHydroToAppFailure(e, st));
  }
}
