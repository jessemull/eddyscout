/// Default recreational kayak speed for trip-time estimates (km/h).
///
/// River current is not modeled; users can override in app settings.
const double kDefaultKayakSpeedKmh = 4;

/// Estimates paddling duration from distance at a constant speed.
int? estimateTripDurationMinutes({
  required double? distanceKm,
  double speedKmh = kDefaultKayakSpeedKmh,
}) {
  if (distanceKm == null || distanceKm <= 0 || speedKmh <= 0) {
    return null;
  }
  return (distanceKm / speedKmh * 60).round();
}
