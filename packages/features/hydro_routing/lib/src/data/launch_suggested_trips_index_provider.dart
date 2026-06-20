import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_exception.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_mapper.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_suggested_trips_index_codec.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_suggested_trips_index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_suggested_trips_index_provider.g.dart';

/// Loads bundled suggested trips index JSON from the app asset bundle.
typedef LaunchSuggestedTripsIndexLoader = Future<String> Function();

/// Override in the app shell with rootBundle.loadString for the index asset.
@Riverpod(keepAlive: true)
LaunchSuggestedTripsIndexLoader launchSuggestedTripsIndexLoader(Ref ref) {
  throw UnimplementedError(
    'Override launchSuggestedTripsIndexLoaderProvider in ProviderScope.',
  );
}

/// Pre-computed launch suggested trips index (one-way and round trips).
@Riverpod(keepAlive: true, retry: disableProviderRetry)
Future<LaunchSuggestedTripsIndex> launchSuggestedTripsIndex(Ref ref) async {
  final load = ref.read(launchSuggestedTripsIndexLoaderProvider);
  try {
    final raw = await load();
    return parseLaunchSuggestedTripsIndex(raw);
  } on Object catch (e, st) {
    throw HydroAppFailureException(mapHydroToAppFailure(e, st));
  }
}
