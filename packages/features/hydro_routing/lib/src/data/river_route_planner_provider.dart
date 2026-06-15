import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_exception.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_mapper.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'river_route_planner_provider.g.dart';

/// Loads bundled hydro GeoJSON from the app asset bundle.
typedef HydroGeoJsonLoader = Future<List<String>> Function();

/// Override in the app shell with rootBundle.loadString for hydro assets.
@Riverpod(keepAlive: true)
HydroGeoJsonLoader hydroGeoJsonLoader(Ref ref) {
  throw UnimplementedError(
    'Override hydroGeoJsonLoaderProvider in ProviderScope (app shell).',
  );
}

/// Bundled hydro graphs for river routing between launches.
@Riverpod(keepAlive: true, retry: disableProviderRetry)
Future<RiverRoutePlanner> riverRoutePlanner(Ref ref) async {
  final load = ref.read(hydroGeoJsonLoaderProvider);
  try {
    final rawDocs = await load();
    return RiverRoutePlanner.fromGeoJsonDocuments(rawDocs);
  } on Object catch (e, st) {
    throw HydroAppFailureException(mapHydroToAppFailure(e, st));
  }
}
