import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/presentation/gpx_actions_provider.dart';

/// Localizes planner, hydro, and GPX failures for map snackbars.
String localizeMapPlannerMessage({
  required AppLocalizations l10n,
  required Object message,
}) => switch (message) {
  RoutePlanningFailure(
    :final code,
    :final riverSystemName,
    :final putInReachId,
    :final takeOutReachId,
  ) =>
    _localizedRouteFailure(
      l10n: l10n,
      code: code,
      riverSystemName: riverSystemName,
      putInReachId: putInReachId,
      takeOutReachId: takeOutReachId,
    ),
  GpxFailure(:final code) => localizeGpxFailureCode(l10n, code),
  StorageFailure(:final message) => localizeGpxStorageFailure(l10n, message),
  ParseFailure() => l10n.mapRiverDataReadFailed,
  AssetLoadFailure() => l10n.mapRiverDataUnavailable,
  String() => message,
  _ => l10n.launchDetailUnavailable,
};

/// Localizes a GPX action failure for export/import outcome snackbars.
String localizeGpxActionFailure({
  required AppLocalizations l10n,
  required GpxActionFailureValue failure,
}) => switch (failure) {
  GpxCodecActionFailure(:final failure) => localizeGpxFailureCode(
    l10n,
    failure.code,
  ),
  GpxPlatformActionFailure(:final failure) => switch (failure) {
    StorageFailure(:final message) => localizeGpxStorageFailure(l10n, message),
    AppFailure() => l10n.mapGpxFailureGeneric,
  },
};

String localizeGpxFailureCode(AppLocalizations l10n, GpxFailureCode code) =>
    switch (code) {
      GpxFailureCode.emptyInput => l10n.mapGpxFailureEmptyInput,
      GpxFailureCode.malformedXml => l10n.mapGpxFailureMalformed,
      GpxFailureCode.noGeometry => l10n.mapGpxFailureNoGeometry,
      GpxFailureCode.tooFewPoints => l10n.mapGpxFailureTooFewPoints,
      GpxFailureCode.noRouteToExport => l10n.mapGpxExportNoRoute,
      GpxFailureCode.fileReadFailed => l10n.mapGpxFailureFileRead,
      GpxFailureCode.fileWriteFailed => l10n.mapGpxFailureFileWrite,
      GpxFailureCode.shareFailed => l10n.mapGpxFailureShare,
      GpxFailureCode.outsidePnw => l10n.mapGpxFailureOutsidePnw,
      GpxFailureCode.launchSnapFailed => l10n.mapGpxFailureLaunchSnapFailed,
    };

String localizeGpxStorageFailure(AppLocalizations l10n, String message) =>
    localizeGpxFailureCode(
      l10n,
      gpxFailureCodeFromAppFailure(StorageFailure(message: message)),
    );

String _localizedRouteFailure({
  required AppLocalizations l10n,
  required RouteFailureCode code,
  required String? riverSystemName,
  String? putInReachId,
  String? takeOutReachId,
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
  RouteFailureCode.disconnectedReach =>
    putInReachId != null &&
            takeOutReachId != null &&
            putInReachId.isNotEmpty &&
            takeOutReachId.isNotEmpty
        ? l10n.mapRouteFailureDisconnectedReachNamed(
            putInReachId,
            takeOutReachId,
          )
        : l10n.mapRouteFailureDisconnectedReach,
};
