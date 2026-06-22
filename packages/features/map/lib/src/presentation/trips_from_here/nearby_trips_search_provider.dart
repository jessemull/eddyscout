import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'nearby_launches_provider.dart';

part 'nearby_trips_search_provider.g.dart';

/// Allowed max-distance filters (statute miles) for nearby trips search.
const kNearbyTripsMaxDistanceOptionsMi = [5, 10, 20];

/// Origin launch for the active nearby trips search session (null = closed).
@Riverpod(keepAlive: true)
class NearbyTripsSearchOrigin extends _$NearbyTripsSearchOrigin {
  @override
  LaunchPoint? build() => null;

  /// Opens search for nearby launches from [origin].
  void open(LaunchPoint origin) {
    ref.read(nearbyTripsSearchQueryProvider.notifier).clear();
    ref.read(nearbyTripsMaxDistanceMiProvider.notifier).reset();
    state = origin;
  }

  /// Closes the nearby trips search session.
  void close() {
    ref.read(nearbyTripsSearchQueryProvider.notifier).clear();
    state = null;
  }
}

/// Max graph-distance (mi) for nearby trips search results.
@riverpod
class NearbyTripsMaxDistanceMi extends _$NearbyTripsMaxDistanceMi {
  @override
  int build() => kNearbyTripsMaxDistanceOptionsMi.last;

  /// Sets the max distance filter in statute miles.
  void setMiles(int miles) {
    if (!kNearbyTripsMaxDistanceOptionsMi.contains(miles)) {
      return;
    }
    state = miles;
  }

  /// Resets to the widest default band.
  void reset() => state = kNearbyTripsMaxDistanceOptionsMi.last;
}

/// Query string for filtering nearby trips search results.
@riverpod
class NearbyTripsSearchQuery extends _$NearbyTripsSearchQuery {
  @override
  String build() => '';

  /// Updates the filter query.
  // ignore: use_setters_to_change_properties — Riverpod notifier API
  void changeQuery(String value) => state = value;

  /// Clears the filter query.
  void clear() => state = '';
}

/// Reachability bands included for a max-distance filter in statute miles.
List<ReachabilityBand> reachabilityBandsUpToMaxMi(int maxMi) {
  return switch (maxMi) {
    <= 5 => [ReachabilityBand.within5Mi],
    <= 10 => [
      ReachabilityBand.within5Mi,
      ReachabilityBand.within10Mi,
    ],
    _ => kReachabilityBandsDisplayOrder,
  };
}

/// Nearby launches within the selected max distance, filtered by query text.
@Riverpod(retry: disableProviderRetry)
Future<List<LaunchPoint>> filteredNearbyTrips(
  Ref ref,
  String originLaunchId,
) async {
  final maxMi = ref.watch(nearbyTripsMaxDistanceMiProvider);
  final query = ref.watch(nearbyTripsSearchQueryProvider).trim().toLowerCase();
  final grouped = await ref.watch(
    nearbyLaunchesGroupedProvider(originLaunchId).future,
  );

  final launches = <LaunchPoint>[];
  for (final band in reachabilityBandsUpToMaxMi(maxMi)) {
    launches.addAll(grouped[band] ?? const []);
  }

  if (query.isEmpty) {
    return launches;
  }

  return launches
      .where((launch) {
        final name = launch.name.toLowerCase();
        final note = launch.shortNote.toLowerCase();
        return name.contains(query) || note.contains(query);
      })
      .toList(growable: false);
}
