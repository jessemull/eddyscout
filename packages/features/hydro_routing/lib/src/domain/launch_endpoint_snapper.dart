import 'dart:math' as math;

import 'package:eddyscout_core/eddyscout_core.dart';

/// Maximum distance (meters) to match GPX endpoints to catalog launches.
const kLaunchSnapThresholdMeters = 2000.0;

/// Snaps imported route endpoints to nearest curated launches within threshold.
abstract final class LaunchEndpointSnapper {
  /// Returns a copy with put-in / take-out set when endpoints match catalog.
  static PlannedRoute snapEndpoints({
    required PlannedRoute route,
    required List<LaunchPoint> catalog,
    double thresholdMeters = kLaunchSnapThresholdMeters,
  }) {
    if (route.points.length < 2 || catalog.isEmpty) {
      return route;
    }

    final first = route.points.first;
    final last = route.points.last;
    final putIn = _nearestLaunch(
      latitude: first.latitude,
      longitude: first.longitude,
      catalog: catalog,
      thresholdMeters: thresholdMeters,
    );
    final takeOut = _nearestLaunch(
      latitude: last.latitude,
      longitude: last.longitude,
      catalog: catalog,
      thresholdMeters: thresholdMeters,
    );

    return route.copyWith(putIn: putIn, takeOut: takeOut);
  }

  static LaunchPoint? _nearestLaunch({
    required double latitude,
    required double longitude,
    required List<LaunchPoint> catalog,
    required double thresholdMeters,
  }) {
    LaunchPoint? best;
    var bestDistance = thresholdMeters;
    for (final launch in catalog) {
      final distance = _haversineMeters(
        latitude,
        longitude,
        launch.latitude,
        launch.longitude,
      );
      if (distance <= bestDistance) {
        bestDistance = distance;
        best = launch;
      }
    }
    return best;
  }

  static double _haversineMeters(
    double lat1Deg,
    double lon1Deg,
    double lat2Deg,
    double lon2Deg,
  ) {
    const earthRadiusM = 6371000.0;
    final lat1 = lat1Deg * math.pi / 180;
    final lat2 = lat2Deg * math.pi / 180;
    final dLat = (lat2Deg - lat1Deg) * math.pi / 180;
    final dLon = (lon2Deg - lon1Deg) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }
}
