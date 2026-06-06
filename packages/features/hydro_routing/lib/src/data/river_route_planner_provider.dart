import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'river_route_planner_provider.g.dart';

/// Loads bundled hydro GeoJSON from the app asset bundle.
typedef HydroGeoJsonLoader = Future<String> Function();

/// Override in the app shell with rootBundle.loadString for the hydro asset.
@Riverpod(keepAlive: true)
HydroGeoJsonLoader hydroGeoJsonLoader(Ref ref) {
  throw UnimplementedError(
    'Override hydroGeoJsonLoaderProvider in ProviderScope (app shell).',
  );
}

/// Bundled hydro graphs for river routing between launches.
@Riverpod(keepAlive: true)
Future<RiverRoutePlanner> riverRoutePlanner(Ref ref) async {
  final load = ref.read(hydroGeoJsonLoaderProvider);
  return RiverRoutePlanner.fromGeoJson(await load());
}
