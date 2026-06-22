import 'package:eddyscout_conditions/src/domain/go_no_go.dart';

/// English fallback text for Firebase payloads
/// (backward-compatible wire format).
///
/// Keep in sync with `launchDetailGoNoGoReason*` keys in
/// `packages/localization/lib/l10n/app_en.arb`.
String goNoGoReasonFallbackMessage(GoNoGoReason reason) =>
    switch (reason.code) {
      GoNoGoReasonCode.coldWaterSeason =>
        'Cold-water season in the PNW—dress for immersion, know '
            'hypothermia risk, and carry safety gear.',
      GoNoGoReasonCode.weatherMissing =>
        reason.weatherError != null
            ? 'Weather data failed to load (${reason.weatherError}). '
                  'Cannot assess wind from forecast.'
            : 'Weather data was not available. '
                  'Cannot assess wind from forecast.',
      GoNoGoReasonCode.windUnknown =>
        'Wind speed or gust was not available from the forecast. Use '
            'caution, especially in open or exposed areas.',
      GoNoGoReasonCode.windHigh =>
        'Effective wind about ${reason.windMph} mph (${reason.exposure} '
            'site)—our stub rules treat this as strong for paddling.',
      GoNoGoReasonCode.windElevated =>
        'Effective wind about ${reason.windMph} mph (${reason.exposure} '
            'site)—conditions may feel rougher on open water.',
      GoNoGoReasonCode.marineSevere =>
        'Marine forecast includes ${reason.pattern}.',
      GoNoGoReasonCode.marineAdvisory =>
        'Marine forecast includes “${reason.pattern}”—expect rougher '
            'water, current, or advisories near the estuary/coast.',
      GoNoGoReasonCode.forecastLowLightHours =>
        'This forecast period starts during typical low-light hours '
            'locally—verify visibility, hazards, and your comfort paddling '
            'after dark.',
      GoNoGoReasonCode.flowVeryHigh =>
        'Discharge is approximately ${reason.cfs} at site ${reason.siteId}.',
      GoNoGoReasonCode.flowHigh => 'Discharge is approximately ${reason.cfs}.',
      GoNoGoReasonCode.flowLow => 'Discharge is approximately ${reason.cfs}.',
    };
