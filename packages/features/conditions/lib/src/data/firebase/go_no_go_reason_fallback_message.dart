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
        'Wind speed or gust was not available from the forecast—use '
            'caution, especially in open or exposed areas.',
      GoNoGoReasonCode.windHigh =>
        'Effective wind about ${reason.windMph} mph (${reason.exposure} '
            'site)—our stub rules treat this as strong for paddling.',
      GoNoGoReasonCode.windElevated =>
        'Effective wind about ${reason.windMph} mph (${reason.exposure} '
            'site)—conditions may feel rougher on open water.',
      GoNoGoReasonCode.marineSevere =>
        'Marine forecast text mentions “${reason.pattern}”—treat as '
            'hazardous until you verify locally.',
      GoNoGoReasonCode.marineAdvisory =>
        'Marine forecast includes “${reason.pattern}”—expect rougher '
            'water, current, or advisories near the estuary/coast.',
      GoNoGoReasonCode.forecastLowLightHours =>
        'This forecast period starts during typical low-light hours '
            'locally—verify visibility, hazards, and your comfort paddling '
            'after dark.',
      GoNoGoReasonCode.flowVeryHigh =>
        reason.usesLaunchFlowBands ?? false
            ? 'Discharge about ${reason.cfs} cfs at site '
                  '${reason.siteId}—above this launch’s curated upper band; '
                  'verify hazards and skill match.'
            : 'Discharge about ${reason.cfs} cfs at site ${reason.siteId}'
                  '—stub upper band for this river class suggests very high '
                  'water; verify hazards and skill match.',
      GoNoGoReasonCode.flowHigh =>
        reason.usesLaunchFlowBands ?? false
            ? 'Discharge about ${reason.cfs} cfs at site '
                  '${reason.siteId}—at or above this launch’s “elevated '
                  'flow” band; double-check strainers and current.'
            : 'Discharge about ${reason.cfs} cfs at site ${reason.siteId}'
                  '—above our placeholder “elevated” band for this river '
                  'class; double-check strainers and current.',
      GoNoGoReasonCode.flowLow =>
        'Discharge about ${reason.cfs} cfs at site '
            '${reason.siteId}—below this launch’s low-flow cue; watch for '
            'shallow spots and wood.',
    };
