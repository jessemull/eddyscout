/// User-facing distance and speed display preference.
enum DisplayUnitSystem {
  /// Kilometers and km/h.
  metric,

  /// Miles and mph.
  imperial,
}

/// SharedPreferences key for [DisplayUnitSystem].
const String kDisplayUnitSystemKey = 'display_unit_system';

/// Default when no preference is stored.
const DisplayUnitSystem kDefaultDisplayUnitSystem = DisplayUnitSystem.metric;

/// Serializes [system] for persistence.
String displayUnitSystemToStored(DisplayUnitSystem system) => switch (system) {
  DisplayUnitSystem.metric => 'metric',
  DisplayUnitSystem.imperial => 'imperial',
};

/// Parses a stored preference value, or null when missing or unrecognized.
DisplayUnitSystem? parseDisplayUnitSystem(String? raw) => switch (raw) {
  'metric' => DisplayUnitSystem.metric,
  'imperial' => DisplayUnitSystem.imperial,
  _ => null,
};
