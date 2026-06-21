import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';

/// Localizes go/no-go verdict headlines for launch detail UI.
String localizeGoNoGoVerdict(AppLocalizations l10n, GoNoGoVerdict verdict) =>
    switch (verdict) {
      GoNoGoVerdict.go => l10n.launchDetailGoNoGoVerdictGo,
      GoNoGoVerdict.marginal => l10n.launchDetailGoNoGoVerdictMarginal,
      GoNoGoVerdict.noGo => l10n.launchDetailGoNoGoVerdictNoGo,
      GoNoGoVerdict.insufficientData =>
        l10n.launchDetailGoNoGoVerdictInsufficientData,
    };

/// Localizes a single go/no-go reason for launch detail UI.
String localizeGoNoGoReason(
  AppLocalizations l10n,
  GoNoGoReason reason,
) => switch (reason.code) {
  GoNoGoReasonCode.coldWaterSeason =>
    l10n.launchDetailGoNoGoReasonColdWaterSeason,
  GoNoGoReasonCode.weatherMissing =>
    reason.weatherError != null
        ? l10n.launchDetailGoNoGoReasonWeatherMissingWithError(
            reason.weatherError!,
          )
        : l10n.launchDetailGoNoGoReasonWeatherMissing,
  GoNoGoReasonCode.windUnknown => l10n.launchDetailGoNoGoReasonWindUnknown,
  GoNoGoReasonCode.windHigh => l10n.launchDetailGoNoGoReasonWindHigh(
    reason.windMph ?? 0,
    reason.exposure ?? '',
  ),
  GoNoGoReasonCode.windElevated => l10n.launchDetailGoNoGoReasonWindElevated(
    reason.windMph ?? 0,
    reason.exposure ?? '',
  ),
  GoNoGoReasonCode.marineSevere => l10n.launchDetailGoNoGoReasonMarineSevere(
    reason.pattern ?? '',
  ),
  GoNoGoReasonCode.marineAdvisory =>
    l10n.launchDetailGoNoGoReasonMarineAdvisory(
      reason.pattern ?? '',
    ),
  GoNoGoReasonCode.forecastLowLightHours =>
    l10n.launchDetailGoNoGoReasonForecastLowLight,
  GoNoGoReasonCode.flowVeryHigh =>
    reason.usesLaunchFlowBands ?? false
        ? l10n.launchDetailGoNoGoReasonFlowVeryHighLaunch(
            reason.cfs ?? '',
            reason.siteId ?? '',
          )
        : l10n.launchDetailGoNoGoReasonFlowVeryHighRiver(
            reason.cfs ?? '',
            reason.siteId ?? '',
          ),
  GoNoGoReasonCode.flowHigh =>
    reason.usesLaunchFlowBands ?? false
        ? l10n.launchDetailGoNoGoReasonFlowHighLaunch(
            reason.cfs ?? '',
            reason.siteId ?? '',
          )
        : l10n.launchDetailGoNoGoReasonFlowHighRiver(
            reason.cfs ?? '',
            reason.siteId ?? '',
          ),
  GoNoGoReasonCode.flowLow => l10n.launchDetailGoNoGoReasonFlowLow(
    reason.cfs ?? '',
    reason.siteId ?? '',
  ),
};

String _titleCaseExposure(String exposure) {
  if (exposure.isEmpty) {
    return exposure;
  }
  return exposure[0].toUpperCase() + exposure.substring(1);
}

/// Route UI sentence lines for one reason (wind-elevated expands to three).
List<String> localizeGoNoGoReasonSentences(
  AppLocalizations l10n,
  GoNoGoReason reason,
) {
  if (reason.code == GoNoGoReasonCode.windElevated) {
    return [
      l10n.launchDetailGoNoGoReasonWindElevatedExposure(
        _formatExposureSiteLabel(reason.exposure ?? ''),
      ),
      l10n.launchDetailGoNoGoReasonWindElevatedSpeed(reason.windMph ?? 0),
      l10n.launchDetailGoNoGoReasonWindElevatedRoughWater,
    ];
  }
  if (reason.code == GoNoGoReasonCode.windHigh) {
    return [
      l10n.launchDetailGoNoGoReasonWindElevatedSpeed(reason.windMph ?? 0),
      l10n.launchDetailGoNoGoReasonWindElevatedExposure(
        _formatExposureSiteLabel(reason.exposure ?? ''),
      ),
      l10n.launchDetailGoNoGoReasonWindHighTooStrong,
    ];
  }
  return [localizeGoNoGoReason(l10n, reason)];
}

/// Joined route summary copy for headers and stop rows.
String localizeGoNoGoReasonRouteSummary(
  AppLocalizations l10n,
  GoNoGoReason reason,
) => localizeGoNoGoReasonSentences(l10n, reason).join(' ');

String _formatExposureSiteLabel(String exposure) {
  if (exposure.isEmpty) {
    return exposure;
  }
  final normalized = exposure.toLowerCase();
  if (normalized.endsWith(' exposure')) {
    final tier = exposure.substring(0, exposure.length - ' exposure'.length);
    return '${_titleCaseExposure(tier)} exposure';
  }
  return '${_titleCaseExposure(exposure)} exposure';
}

/// Localizes per-stop failure copy for route go/no-go partial-failure lines.
String localizeRouteGoNoGoFailureMessage(
  AppLocalizations l10n,
  AppFailure failure,
) => switch (failure) {
  NotFoundFailure() => l10n.routeGoNoGoLaunchNotFound,
  _ => failure.message,
};

/// One-line summary for a waypoint go/no-go row (primary reason or none).
String? waypointGoNoGoSummaryLine(
  AppLocalizations l10n,
  GoNoGoResult result,
) {
  final bullets = waypointGoNoGoSummarySentences(l10n, result);
  if (bullets.isEmpty) {
    return null;
  }
  return bullets.join(' ');
}

/// Sentence lines for route go/no-go stop rows and headers.
List<String> waypointGoNoGoSummarySentences(
  AppLocalizations l10n,
  GoNoGoResult result,
) {
  final reasons = result.reasons
      .where(
        (reason) =>
            reason.severity != GoNoGoReasonSeverity.info ||
            reason.code == GoNoGoReasonCode.weatherMissing,
      )
      .toList();
  if (reasons.isEmpty) {
    return result.verdict == GoNoGoVerdict.go
        ? [l10n.launchDetailGoNoGoNoWarnings]
        : const [];
  }
  return localizeGoNoGoReasonSentences(l10n, reasons.first);
}
