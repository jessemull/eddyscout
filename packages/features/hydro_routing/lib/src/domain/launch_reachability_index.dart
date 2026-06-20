import 'package:freezed_annotation/freezed_annotation.dart';

part 'launch_reachability_index.freezed.dart';

/// Exclusive distance bands for nearby launches.
///
/// Distances follow the river graph, not crow-flies.
enum ReachabilityBand {
  /// Launches within 5 statute miles along the river graph.
  within5Mi('5mi'),

  /// Launches within (5, 10] statute miles.
  within10Mi('10mi'),

  /// Launches within (10, 20] statute miles.
  within20Mi('20mi');

  const ReachabilityBand(this.jsonKey);

  /// Key used in the bundled reachability JSON artifact.
  final String jsonKey;
}

/// Statute miles converted to meters for reachability thresholds.
const kReachabilityMilesToMeters = 1609.344;

/// Default snap threshold when generating or querying the reachability index.
const kReachabilitySnapMaxMeters = 900.0;

/// Reachability thresholds in statute miles (exclusive upper bands).
const kReachabilityThresholdsMi = [5, 10, 20];

/// Nearby launch ids grouped by exclusive distance band for one catalog launch.
@freezed
abstract class LaunchReachabilityEntry with _$LaunchReachabilityEntry {
  /// Creates one source launch entry in the reachability index.
  const factory LaunchReachabilityEntry({
    @Default([]) List<String> within5Mi,
    @Default([]) List<String> within10Mi,
    @Default([]) List<String> within20Mi,
  }) = _LaunchReachabilityEntry;

  const LaunchReachabilityEntry._();

  /// Launch ids in the requested [band], or empty when the band is unknown.
  List<String> launchIdsFor(ReachabilityBand band) => switch (band) {
    ReachabilityBand.within5Mi => within5Mi,
    ReachabilityBand.within10Mi => within10Mi,
    ReachabilityBand.within20Mi => within20Mi,
  };
}

/// Pre-computed graph-distance reachability for the launch catalog.
@freezed
abstract class LaunchReachabilityIndex with _$LaunchReachabilityIndex {
  /// Creates a parsed reachability index artifact.
  const factory LaunchReachabilityIndex({
    required int schemaVersion,
    required DateTime generatedAt,
    required String distanceModel,
    required double snapMaxMeters,
    required List<int> thresholdsMi,
    required bool crossSystemReachability,
    required Map<String, LaunchReachabilityEntry> entries,
  }) = _LaunchReachabilityIndex;

  const LaunchReachabilityIndex._();

  /// Entry for [launchId], or null when the launch is absent from the index.
  LaunchReachabilityEntry? entryFor(String launchId) => entries[launchId];

  /// Nearby launch ids for [fromLaunchId] within [band], or empty when unknown.
  List<String> nearbyLaunchIds(String fromLaunchId, ReachabilityBand band) {
    final entry = entryFor(fromLaunchId);
    if (entry == null) {
      return const [];
    }
    return entry.launchIdsFor(band);
  }
}

/// Returns the exclusive band for [distanceMeters], or null when beyond 20 mi.
ReachabilityBand? reachabilityBandForDistance(double distanceMeters) {
  const five = 5 * kReachabilityMilesToMeters;
  const ten = 10 * kReachabilityMilesToMeters;
  const twenty = 20 * kReachabilityMilesToMeters;
  if (distanceMeters <= five) {
    return ReachabilityBand.within5Mi;
  }
  if (distanceMeters <= ten) {
    return ReachabilityBand.within10Mi;
  }
  if (distanceMeters <= twenty) {
    return ReachabilityBand.within20Mi;
  }
  return null;
}
