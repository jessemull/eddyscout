import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
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
