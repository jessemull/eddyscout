import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';

/// Localizes planner and hydro failures for map snackbars.
String localizeMapPlannerMessage({
  required AppLocalizations l10n,
  required Object message,
}) => switch (message) {
  RouteFailure(:final code, :final riverSystemName) => _localizedRouteFailure(
    l10n: l10n,
    code: code,
    riverSystemName: riverSystemName,
  ),
  ParseFailure() => l10n.mapRiverDataReadFailed,
  AssetLoadFailure() => l10n.mapRiverDataUnavailable,
  String() => message,
  _ => l10n.launchDetailUnavailable,
};

String _localizedRouteFailure({
  required AppLocalizations l10n,
  required RouteFailureCode code,
  required String? riverSystemName,
}) => switch (code) {
  RouteFailureCode.sameLaunch => l10n.mapRouteFailureSameLaunch,
  RouteFailureCode.differentSystem => l10n.mapRouteFailureDifferentSystem,
  RouteFailureCode.noBundledLine => l10n.mapRouteFailureNoBundledLine(
    riverSystemName ?? '',
  ),
  RouteFailureCode.noRiverGeometryLoaded => l10n.mapRouteFailureNoData,
  RouteFailureCode.putInTooFar => l10n.mapRouteFailurePutInTooFar,
  RouteFailureCode.takeOutTooFar => l10n.mapRouteFailureTakeOutTooFar,
  RouteFailureCode.noConnectedPath => l10n.mapRouteFailureNoConnectedPath,
};
