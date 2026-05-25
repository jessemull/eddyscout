import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads bundled hydro GeoJSON from the app asset bundle.
typedef HydroGeoJsonLoader = Future<String> Function();

/// Override in the app shell with rootBundle.loadString for the hydro asset.
final hydroGeoJsonLoaderProvider = Provider<HydroGeoJsonLoader>((ref) {
  throw UnimplementedError(
    'Override hydroGeoJsonLoaderProvider in ProviderScope (app shell).',
  );
});

/// Bundled hydro graphs for river routing between launches.
final riverRoutePlannerProvider = FutureProvider<RiverRoutePlanner>((
  ref,
) async {
  ref.keepAlive();
  final load = ref.read(hydroGeoJsonLoaderProvider);
  return RiverRoutePlanner.fromGeoJson(await load());
});
