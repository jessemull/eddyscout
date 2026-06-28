import 'package:eddyscout_core/src/geodesy.dart';
import 'package:eddyscout_core/src/launch_models.dart';

/// Minimum separation (meters) between access and water entry before the map
/// shows a distinct water-entry indicator.
const kDistinctWaterEntryThresholdMeters = 10.0;

/// Access vs routing coordinate accessors for [LaunchPoint].
extension LaunchPointCoordinates on LaunchPoint {
  /// Map marker / parking / park-entrance latitude ([LaunchPoint.latitude]).
  double get accessLatitude => latitude;

  /// Map marker / parking / park-entrance longitude ([LaunchPoint.longitude]).
  double get accessLongitude => longitude;

  /// Hydro routing snap latitude (water entry when set, else access).
  double get routingLatitude => waterEntryLatitude ?? latitude;

  /// Hydro routing snap longitude (water entry when set, else access).
  double get routingLongitude => waterEntryLongitude ?? longitude;

  /// True when an explicit water-entry point differs meaningfully from access.
  bool get hasDistinctWaterEntry {
    if (waterEntryLatitude == null || waterEntryLongitude == null) {
      return false;
    }
    return haversineMeters(
          latitude,
          longitude,
          waterEntryLatitude!,
          waterEntryLongitude!,
        ) >
        kDistinctWaterEntryThresholdMeters;
  }
}
