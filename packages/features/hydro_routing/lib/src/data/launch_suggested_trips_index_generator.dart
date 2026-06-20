import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_suggested_trips_index_codec.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_suggested_trips_index.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';
import 'package:eddyscout_hydro_routing/src/domain/suggested_trip_waypoints.dart';

/// Builds a pre-computed suggested trips index from hydro graphs and catalog.
abstract final class LaunchSuggestedTripsIndexGenerator {
  /// Generates an index using graph routing between catalog launches.
  ///
  /// Cross-system pairs are excluded when [crossSystemReachability] is false.
  static LaunchSuggestedTripsIndex generate({
    required RiverRoutePlanner planner,
    required List<LaunchPoint> catalog,
    DateTime? generatedAt,
    bool crossSystemReachability = false,
    int maxOneWaySuggestions = kSuggestedTripsMaxOneWay,
    int maxRoundTripSuggestions = kSuggestedTripsMaxRoundTrip,
    double paddleSpeedKmh = kSuggestedTripsDefaultPaddleSpeedKmh,
    void Function(String message)? onWarning,
  }) {
    final entries = <String, LaunchSuggestedTripsEntry>{};

    for (final source in catalog) {
      final candidates = <({LaunchPoint target, RouteSuccess route})>[];

      for (final target in catalog) {
        if (source.id == target.id) {
          continue;
        }
        if (!crossSystemReachability &&
            source.riverSystem != target.riverSystem) {
          continue;
        }

        final result = planner.plan(source, target);
        if (result is! RouteSuccess) {
          continue;
        }
        if (result.lengthMeters > kSuggestedTripsMaxDistanceMeters) {
          continue;
        }

        candidates.add((target: target, route: result));
      }

      candidates.sort((a, b) {
        final byDist = a.route.lengthMeters.compareTo(b.route.lengthMeters);
        if (byDist != 0) {
          return byDist;
        }
        return a.target.id.compareTo(b.target.id);
      });

      final topOneWay = candidates.take(maxOneWaySuggestions).toList();
      final oneWayTrips = topOneWay
          .map(
            (candidate) => _buildOneWayTrip(
              source: source,
              target: candidate.target,
              route: candidate.route,
              catalog: catalog,
              paddleSpeedKmh: paddleSpeedKmh,
            ),
          )
          .toList();

      final roundTrips = oneWayTrips
          .take(maxRoundTripSuggestions)
          .map(_buildRoundTripFromOneWay)
          .toList();

      entries[source.id] = LaunchSuggestedTripsEntry(
        oneWay: oneWayTrips,
        roundTrips: roundTrips,
      );

      if (oneWayTrips.isEmpty && onWarning != null) {
        final sameSystemPeer = catalog.where(
          (launch) =>
              launch.id != source.id &&
              launch.riverSystem == source.riverSystem,
        );
        if (sameSystemPeer.isEmpty) {
          onWarning(
            'Launch ${source.id} has no routable peers on '
            '${source.riverSystem.name}',
          );
        }
      }
    }

    return LaunchSuggestedTripsIndex(
      schemaVersion: 1,
      generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
      distanceModel: 'graph_plus_snap',
      snapMaxMeters: kReachabilitySnapMaxMeters,
      maxDistanceMi: kSuggestedTripsMaxDistanceMi,
      paddleSpeedKmh: paddleSpeedKmh,
      maxOneWaySuggestions: maxOneWaySuggestions,
      maxRoundTripSuggestions: maxRoundTripSuggestions,
      crossSystemReachability: crossSystemReachability,
      entries: entries,
    );
  }

  /// Generates and encodes the index as JSON text.
  static String generateJson({
    required RiverRoutePlanner planner,
    required List<LaunchPoint> catalog,
    DateTime? generatedAt,
    bool crossSystemReachability = false,
    int maxOneWaySuggestions = kSuggestedTripsMaxOneWay,
    int maxRoundTripSuggestions = kSuggestedTripsMaxRoundTrip,
    double paddleSpeedKmh = kSuggestedTripsDefaultPaddleSpeedKmh,
    void Function(String message)? onWarning,
  }) {
    final index = generate(
      planner: planner,
      catalog: catalog,
      generatedAt: generatedAt,
      crossSystemReachability: crossSystemReachability,
      maxOneWaySuggestions: maxOneWaySuggestions,
      maxRoundTripSuggestions: maxRoundTripSuggestions,
      paddleSpeedKmh: paddleSpeedKmh,
      onWarning: onWarning,
    );
    return encodeLaunchSuggestedTripsIndex(index);
  }

  static SuggestedTrip _buildOneWayTrip({
    required LaunchPoint source,
    required LaunchPoint target,
    required RouteSuccess route,
    required List<LaunchPoint> catalog,
    required double paddleSpeedKmh,
  }) {
    final distanceKm = route.lengthMeters / 1000;
    final waypoints = suggestedTripWaypoints(
      polylineLonLat: route.polylineLonLat,
      source: source,
      destination: target,
      catalog: catalog,
    );
    final minutes = estimateSuggestedTripMinutes(
      distanceKm: distanceKm,
      speedKmh: paddleSpeedKmh,
    );

    return SuggestedTrip(
      destination: target.id,
      distanceKm: distanceKm,
      estimatedMinutes: minutes ?? 0,
      waypoints: waypoints,
    );
  }

  static SuggestedTrip _buildRoundTripFromOneWay(SuggestedTrip oneWay) {
    final roundDistanceKm = oneWay.distanceKm * 2;
    final roundMinutes = oneWay.estimatedMinutes * 2;
    final sourceId = oneWay.waypoints.first;
    return SuggestedTrip(
      destination: oneWay.destination,
      distanceKm: roundDistanceKm,
      estimatedMinutes: roundMinutes,
      waypoints: [...oneWay.waypoints, sourceId],
    );
  }
}
