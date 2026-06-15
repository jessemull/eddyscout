import 'dart:math' as math;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Screen-space radius for treating a map tap as a launch marker hit.
const double kLaunchMarkerTapRadiusPx = 36;

/// Returns the nearest launch within [maxRadiusPx] of [tap], if any.
Future<LaunchPoint?> nearestLaunchAtScreenPoint({
  required List<LaunchPoint> launches,
  required ScreenCoordinate tap,
  required Future<ScreenCoordinate> Function(LaunchPoint launch) launchToPixel,
  double maxRadiusPx = kLaunchMarkerTapRadiusPx,
}) async {
  final maxRadiusSq = maxRadiusPx * maxRadiusPx;
  LaunchPoint? nearest;
  var bestRadiusSq = maxRadiusSq;
  for (final launch in launches) {
    final pixel = await launchToPixel(launch);
    final dx = pixel.x - tap.x;
    final dy = pixel.y - tap.y;
    final radiusSq = dx * dx + dy * dy;
    if (radiusSq <= bestRadiusSq) {
      bestRadiusSq = radiusSq;
      nearest = launch;
    }
  }
  return nearest;
}

/// Screen-space distance between two coordinates (for tests).
double screenDistancePx(ScreenCoordinate a, ScreenCoordinate b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return math.sqrt(dx * dx + dy * dy);
}
