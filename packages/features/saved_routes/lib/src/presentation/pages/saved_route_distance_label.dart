import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';

/// Localized saved-route distance label from stored meters.
String? formatSavedRouteDistanceLabel(
  AppLocalizations l10n,
  double? distanceMeters,
  DisplayUnitSystem units,
) {
  if (distanceMeters == null) {
    return null;
  }
  final numeric = formatDistanceNumeric(distanceMeters / 1000, units);
  if (numeric == null) {
    return null;
  }
  return switch (units) {
    DisplayUnitSystem.metric => l10n.savedRoutesDistanceKm(numeric),
    DisplayUnitSystem.imperial => l10n.savedRoutesDistanceMi(numeric),
  };
}
