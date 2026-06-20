import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/generated/app_localizations.dart';

/// Localized distance string from [formatted].
String localizedDistance(
  AppLocalizations l10n,
  FormattedDistance formatted,
) => switch (formatted.unit) {
  DistanceUnit.km => l10n.displayDistanceKm(formatted.value),
  DistanceUnit.mi => l10n.displayDistanceMi(formatted.value),
};

/// Localized speed string from [formatted].
String localizedSpeed(AppLocalizations l10n, FormattedSpeed formatted) =>
    switch (formatted.unit) {
      SpeedUnit.kmh => l10n.displaySpeedKmh(formatted.value),
      SpeedUnit.mph => l10n.displaySpeedMph(formatted.value),
    };

/// Localized distance from [km] under [system], or null when invalid.
String? localizedDistanceFromKm(
  AppLocalizations l10n,
  double? km,
  DisplayUnitSystem system,
) {
  final formatted = formatDistanceFromKm(km, system);
  if (formatted == null) {
    return null;
  }
  return localizedDistance(l10n, formatted);
}

/// Localized distance from [meters] under [system], or null when invalid.
String? localizedDistanceFromMeters(
  AppLocalizations l10n,
  double? meters,
  DisplayUnitSystem system,
) {
  final formatted = formatDistanceFromMeters(meters, system);
  if (formatted == null) {
    return null;
  }
  return localizedDistance(l10n, formatted);
}

/// Localized speed from stored km/h under [system].
String localizedSpeedFromKmh(
  AppLocalizations l10n,
  double kmh,
  DisplayUnitSystem system,
) => localizedSpeed(l10n, formatSpeedFromKmh(kmh, system));
