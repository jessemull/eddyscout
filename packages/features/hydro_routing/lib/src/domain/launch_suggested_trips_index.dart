import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'launch_suggested_trips_index.freezed.dart';

/// Trip directionality for query helpers (JSON uses separate arrays).
enum SuggestedTripKind {
  /// One-way paddle from source launch to destination.
  oneWay,

  /// Out-and-back paddle returning to the source launch.
  roundTrip,
}

/// Maximum one-way suggestions stored per source launch.
const kSuggestedTripsMaxOneWay = 8;

/// Maximum round-trip suggestions derived from the nearest one-way trips.
const kSuggestedTripsMaxRoundTrip = 5;

/// Default paddling speed baked into pre-computed time estimates (km/h).
///
/// Matches the map feature default of 4 km/h; UI may rescale later.
const kSuggestedTripsDefaultPaddleSpeedKmh = 4.0;

/// Maximum graph distance for suggested trips (statute miles).
const kSuggestedTripsMaxDistanceMi = 20;

/// Maximum graph distance for suggested trips (meters).
const double kSuggestedTripsMaxDistanceMeters =
    kSuggestedTripsMaxDistanceMi * kReachabilityMilesToMeters;

/// A pre-computed trip suggestion between catalog launches.
@freezed
abstract class SuggestedTrip with _$SuggestedTrip {
  /// Creates one suggested trip entry.
  const factory SuggestedTrip({
    required String destination,
    required double distanceKm,
    required int estimatedMinutes,
    required List<String> waypoints,
  }) = _SuggestedTrip;
}

/// One-way and round-trip suggestions for a single source launch.
@freezed
abstract class LaunchSuggestedTripsEntry with _$LaunchSuggestedTripsEntry {
  /// Creates suggestions for one catalog launch.
  const factory LaunchSuggestedTripsEntry({
    @Default([]) List<SuggestedTrip> oneWay,
    @Default([]) List<SuggestedTrip> roundTrips,
  }) = _LaunchSuggestedTripsEntry;

  const LaunchSuggestedTripsEntry._();

  /// Suggestions for [kind], or empty when unknown.
  List<SuggestedTrip> tripsFor(SuggestedTripKind kind) => switch (kind) {
    SuggestedTripKind.oneWay => oneWay,
    SuggestedTripKind.roundTrip => roundTrips,
  };
}

/// Pre-computed suggested trips for the launch catalog.
@freezed
abstract class LaunchSuggestedTripsIndex with _$LaunchSuggestedTripsIndex {
  /// Creates a parsed suggested trips index artifact.
  const factory LaunchSuggestedTripsIndex({
    required int schemaVersion,
    required DateTime generatedAt,
    required String distanceModel,
    required double snapMaxMeters,
    required int maxDistanceMi,
    required double paddleSpeedKmh,
    required int maxOneWaySuggestions,
    required int maxRoundTripSuggestions,
    required bool crossSystemReachability,
    required Map<String, LaunchSuggestedTripsEntry> entries,
  }) = _LaunchSuggestedTripsIndex;

  const LaunchSuggestedTripsIndex._();

  /// Entry for [launchId], or null when absent from the index.
  LaunchSuggestedTripsEntry? entryFor(String launchId) => entries[launchId];

  /// One-way suggestions for [launchId], or empty when unknown.
  List<SuggestedTrip> oneWayTripsFor(String launchId) =>
      entryFor(launchId)?.oneWay ?? const [];

  /// Round-trip suggestions for [launchId], or empty when unknown.
  List<SuggestedTrip> roundTripsFor(String launchId) =>
      entryFor(launchId)?.roundTrips ?? const [];
}

/// Estimates paddling duration from distance at a constant speed.
int? estimateSuggestedTripMinutes({
  required double distanceKm,
  double speedKmh = kSuggestedTripsDefaultPaddleSpeedKmh,
}) {
  if (distanceKm <= 0 || speedKmh <= 0) {
    return null;
  }
  return (distanceKm / speedKmh * 60).round();
}
