import '../conditions/conditions_models.dart';
import '../data/launch_models.dart';
import '../decision/go_no_go.dart';

/// JSON-safe payload for Cloud Functions (`summarizeConditions`) and logging.
/// Keep in sync with `firebase/functions` zod schema.
Map<String, Object?> conditionsSummaryPayload({
  required LaunchPoint launch,
  required ConditionsSnapshot snapshot,
  required GoNoGoResult goNoGo,
  required GoNoGoProfile skillProfile,
}) {
  return {
    'launch': _launchJson(launch, skillProfile),
    'snapshot': _snapshotJson(snapshot),
    'goNoGo': _goNoGoJson(goNoGo),
  };
}

Map<String, Object?> _launchJson(
  LaunchPoint launch,
  GoNoGoProfile skillProfile,
) {
  return {
    'id': launch.id,
    'name': launch.name,
    'latitude': launch.latitude,
    'longitude': launch.longitude,
    'shortNote': launch.shortNote,
    'riverSystem': launch.riverSystem.name,
    'windExposure': launch.windExposure.name,
    'tideRelevance': launch.tideRelevance.name,
    'noaaTideStationId': launch.noaaTideStationId,
    'marineZoneId': launch.marineZoneId,
    'usgsSiteId': launch.usgsSiteId,
    'flowBands': launch.flowBands == null
        ? null
        : {
            'cfsMarginalBelow': launch.flowBands!.cfsMarginalBelow,
            'cfsComfortMax': launch.flowBands!.cfsComfortMax,
            'cfsNoGoAbove': launch.flowBands!.cfsNoGoAbove,
          },
    'skillProfile': skillProfile.name,
  };
}

Map<String, Object?> _snapshotJson(ConditionsSnapshot s) {
  return {
    'fetchedAt': s.fetchedAt.toUtc().toIso8601String(),
    'weather': s.weather == null ? null : _weatherJson(s.weather!),
    'weatherError': s.weatherError,
    'tides': s.tides == null ? null : _tidesJson(s.tides!),
    'tideError': s.tideError,
    'marine': s.marine == null ? null : _marineJson(s.marine!),
    'marineError': s.marineError,
    'riverFlow': s.riverFlow == null ? null : _riverJson(s.riverFlow!),
    'riverError': s.riverError,
  };
}

Map<String, Object?> _weatherJson(WeatherConditions w) {
  return {
    'temperatureF': w.temperatureF,
    'windSpeedMph': w.windSpeedMph,
    'windGustMph': w.windGustMph,
    'windDirection': w.windDirection,
    'shortForecast': w.shortForecast,
    'periodStart': w.periodStart?.toUtc().toIso8601String(),
    'source': w.source.name,
  };
}

Map<String, Object?> _tidesJson(TideSummary t) {
  return {
    'stationId': t.stationId,
    'datumLabel': t.datumLabel,
    'referenceNote': t.referenceNote,
    'events': t.events
        .map(
          (e) => {
            'type': e.type,
            'heightFt': e.heightFt,
            'time': e.time.toUtc().toIso8601String(),
          },
        )
        .toList(),
  };
}

Map<String, Object?> _marineJson(MarineSummary m) {
  return {
    'zoneId': m.zoneId,
    'periods': m.periods
        .map((p) => {'name': p.name, 'detailedForecast': p.detailedForecast})
        .toList(),
  };
}

Map<String, Object?> _riverJson(RiverFlowReading r) {
  return {
    'siteId': r.siteId,
    'cfs': r.cfs,
    'observedAt': r.observedAt.toUtc().toIso8601String(),
  };
}

Map<String, Object?> _goNoGoJson(GoNoGoResult g) {
  return {
    'verdict': g.verdict.name,
    'computedAt': g.computedAt.toUtc().toIso8601String(),
    'reasons': g.reasons
        .map(
          (r) => {
            'code': r.code,
            'message': r.message,
            'severity': r.severity.name,
          },
        )
        .toList(),
  };
}
