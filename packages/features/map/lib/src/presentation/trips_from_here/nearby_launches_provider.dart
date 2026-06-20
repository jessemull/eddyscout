import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nearby_launches_provider.g.dart';

/// Display order for reachability bands in trips-from-here UI.
const kReachabilityBandsDisplayOrder = <ReachabilityBand>[
  ReachabilityBand.within5Mi,
  ReachabilityBand.within10Mi,
  ReachabilityBand.within20Mi,
];

/// Inputs for [nearbyLaunchesForBandProvider].
typedef NearbyLaunchesBandParams = ({
  String originLaunchId,
  ReachabilityBand band,
});

/// Resolves catalog launches for one reachability band from a source launch.
@riverpod
Future<List<LaunchPoint>> nearbyLaunchesForBand(
  Ref ref,
  NearbyLaunchesBandParams params,
) async {
  final index = await ref.watch(launchReachabilityIndexProvider.future);
  final ids = index.nearbyLaunchIds(params.originLaunchId, params.band);
  return _resolveLaunchIds(ids);
}

/// Nearby launches grouped by exclusive reachability band.
@riverpod
Future<Map<ReachabilityBand, List<LaunchPoint>>> nearbyLaunchesGrouped(
  Ref ref,
  String originLaunchId,
) async {
  final index = await ref.watch(launchReachabilityIndexProvider.future);
  final grouped = <ReachabilityBand, List<LaunchPoint>>{};
  for (final band in kReachabilityBandsDisplayOrder) {
    final ids = index.nearbyLaunchIds(originLaunchId, band);
    grouped[band] = _resolveLaunchIds(ids);
  }
  return grouped;
}

List<LaunchPoint> _resolveLaunchIds(List<String> ids) {
  final launches = <LaunchPoint>[];
  for (final id in ids) {
    final launch = findLaunchPointById(id);
    if (launch != null) {
      launches.add(launch);
    }
  }
  return launches;
}

/// Signals map screen to run hydro routing after returning from launch detail.
@Riverpod(keepAlive: true)
class TripsFromHereRoutePending extends _$TripsFromHereRoutePending {
  @override
  bool build() => false;

  /// Marks that route planning was pre-filled and needs a map route run.
  void markPending() => state = true;

  /// Clears the pending flag after the map consumes it.
  void clear() => state = false;
}

/// Whether suggested trips index is wired (v2 extension point).
@Riverpod(keepAlive: true)
bool suggestedTripsIndexAvailable(Ref ref) => false;
