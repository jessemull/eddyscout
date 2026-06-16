/// User-facing distance and speed unit preference.
enum DisplayUnitSystem {
  /// Kilometers and km/h.
  metric,

  /// Miles and mph.
  imperial,
}

/// SharedPreferences key for [DisplayUnitSystem].
const String kDisplayUnitSystemKey = 'display_unit_system';

/// Kilometers per mile conversion factor.
const double kKmPerMile = 0.621371;

/// Parses a persisted unit preference string.
DisplayUnitSystem parseDisplayUnitSystem(String? raw) => switch (raw) {
  'imperial' => DisplayUnitSystem.imperial,
  'metric' => DisplayUnitSystem.metric,
  _ => DisplayUnitSystem.metric,
};

/// Encodes [units] for persistence.
String encodeDisplayUnitSystem(DisplayUnitSystem units) => switch (units) {
  DisplayUnitSystem.metric => 'metric',
  DisplayUnitSystem.imperial => 'imperial',
};

/// Converts [speedKmh] to mph.
double kmhToMph(double speedKmh) => speedKmh * kKmPerMile;

/// Formats route distance for display (one decimal place).
///
/// Returns null when [distanceKm] is null or non-positive.
String? formatDistanceNumeric(double? distanceKm, DisplayUnitSystem units) {
  if (distanceKm == null || distanceKm <= 0) {
    return null;
  }
  return switch (units) {
    DisplayUnitSystem.metric => distanceKm.toStringAsFixed(1),
    DisplayUnitSystem.imperial => (distanceKm * kKmPerMile).toStringAsFixed(1),
  };
}

/// Formats paddling speed for display (one decimal place).
String formatSpeedNumeric(double speedKmh, DisplayUnitSystem units) =>
    switch (units) {
      DisplayUnitSystem.metric => speedKmh.toStringAsFixed(1),
      DisplayUnitSystem.imperial => kmhToMph(speedKmh).toStringAsFixed(1),
    };
