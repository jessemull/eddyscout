import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_exception.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_mapper.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_reachability_index_codec.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_reachability_index_provider.g.dart';

/// Loads bundled reachability index JSON from the app asset bundle.
typedef LaunchReachabilityIndexLoader = Future<String> Function();

/// Override in the app shell with rootBundle.loadString for the index asset.
@Riverpod(keepAlive: true)
LaunchReachabilityIndexLoader launchReachabilityIndexLoader(Ref ref) {
  throw UnimplementedError(
    'Override launchReachabilityIndexLoaderProvider in ProviderScope.',
  );
}

/// Pre-computed launch reachability index (graph distance bands).
@Riverpod(keepAlive: true, retry: disableProviderRetry)
Future<LaunchReachabilityIndex> launchReachabilityIndex(Ref ref) async {
  final load = ref.read(launchReachabilityIndexLoaderProvider);
  try {
    final raw = await load();
    return parseLaunchReachabilityIndex(raw);
  } on Object catch (e, st) {
    throw HydroAppFailureException(mapHydroToAppFailure(e, st));
  }
}
