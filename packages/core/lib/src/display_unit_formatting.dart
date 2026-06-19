import 'package:eddyscout_core/src/display_unit_system.dart';
import 'package:meta/meta.dart';

/// Distance unit used in a formatted display value.
enum DistanceUnit {
  /// Kilometers.
  km,

  /// Miles.
  mi,
}

/// Speed unit used in a formatted display value.
enum SpeedUnit {
  /// Kilometers per hour.
  kmh,

  /// Miles per hour.
  mph,
}

/// A distance value ready for localization (numeric string + unit).
@immutable
class FormattedDistance {
  /// Creates a formatted distance.
  const FormattedDistance({required this.value, required this.unit});

  /// Numeric portion (one decimal place).
  final String value;

  /// Unit discriminator for l10n templates.
  final DistanceUnit unit;
}

/// A speed value ready for localization (numeric string + unit).
@immutable
class FormattedSpeed {
  /// Creates a formatted speed.
  const FormattedSpeed({required this.value, required this.unit});

  /// Numeric portion (one decimal place).
  final String value;

  /// Unit discriminator for l10n templates.
  final SpeedUnit unit;
}

const double _kmToMi = 0.621371;

/// Formats [km] for display under [system], or null when invalid.
FormattedDistance? formatDistanceFromKm(
  double? km,
  DisplayUnitSystem system,
) {
  if (km == null || km <= 0) {
    return null;
  }
  return switch (system) {
    DisplayUnitSystem.metric => FormattedDistance(
      value: km.toStringAsFixed(1),
      unit: DistanceUnit.km,
    ),
    DisplayUnitSystem.imperial => FormattedDistance(
      value: (km * _kmToMi).toStringAsFixed(1),
      unit: DistanceUnit.mi,
    ),
  };
}

/// Formats [meters] for display under [system], or null when invalid.
FormattedDistance? formatDistanceFromMeters(
  double? meters,
  DisplayUnitSystem system,
) {
  if (meters == null || meters <= 0) {
    return null;
  }
  return formatDistanceFromKm(meters / 1000, system);
}

/// Formats [kmh] for display under [system].
FormattedSpeed formatSpeedFromKmh(double kmh, DisplayUnitSystem system) =>
    switch (system) {
      DisplayUnitSystem.metric => FormattedSpeed(
        value: kmh.toStringAsFixed(1),
        unit: SpeedUnit.kmh,
      ),
      DisplayUnitSystem.imperial => FormattedSpeed(
        value: (kmh * _kmToMi).toStringAsFixed(1),
        unit: SpeedUnit.mph,
      ),
    };
