import 'package:flutter_test/flutter_test.dart';

import 'package:eddyscout/conditions/conditions_models.dart';
import 'package:eddyscout/data/launch_models.dart';
import 'package:eddyscout/decision/go_no_go.dart';

LaunchPoint _launch({
  WindExposure exposure = WindExposure.moderate,
  RiverSystem river = RiverSystem.willamette,
  String? marineZoneId,
}) {
  return LaunchPoint(
    id: 'test',
    name: 'Test',
    latitude: 45.5,
    longitude: -122.6,
    shortNote: 'Test',
    riverSystem: river,
    windExposure: exposure,
    tideRelevance: TideRelevance.none,
    marineZoneId: marineZoneId,
    usgsSiteId: '14211720',
  );
}

WeatherConditions _wx({int? speed, int? gust}) {
  return WeatherConditions(
    temperatureF: 55,
    windSpeedMph: speed,
    windGustMph: gust,
    windDirection: 'N',
    shortForecast: 'Fair',
    periodStart: DateTime.parse('2026-06-15T12:00:00-07:00'),
    source: WeatherDataSource.nws,
  );
}

void main() {
  test('calm wind moderate exposure → go', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(),
      ConditionsSnapshot(
        fetchedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
        weather: _wx(speed: 5, gust: 6),
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.go);
    expect(r.reasons.where((x) => x.severity != GoNoGoReasonSeverity.info).isEmpty, true);
  });

  test('high gust exposed → noGo', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(exposure: WindExposure.exposed),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: _wx(speed: 8, gust: 25),
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.noGo);
    expect(r.reasons.any((x) => x.code == 'wind_high'), true);
  });

  test('elevated wind moderate → marginal', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(exposure: WindExposure.moderate),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: _wx(speed: 18, gust: 18),
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.marginal);
    expect(r.reasons.any((x) => x.code == 'wind_elevated'), true);
  });

  test('marine small craft → marginal', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(marineZoneId: 'PZZ210'),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: _wx(speed: 5, gust: 5),
        marine: MarineSummary(
          zoneId: 'PZZ210',
          periods: [
            MarinePeriod(
              name: 'Today',
              detailedForecast: 'SMALL CRAFT ADVISORY IN EFFECT. NW wind 15 kt.',
            ),
          ],
        ),
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.marginal);
    expect(r.reasons.any((x) => x.code == 'marine_advisory'), true);
  });

  test('marine storm warning → noGo overrides marginal wind', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(marineZoneId: 'PZZ210', exposure: WindExposure.sheltered),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: _wx(speed: 5, gust: 5),
        marine: MarineSummary(
          zoneId: 'PZZ210',
          periods: [
            MarinePeriod(
              name: 'Today',
              detailedForecast: 'STORM WARNING IN EFFECT for coastal waters.',
            ),
          ],
        ),
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.noGo);
    expect(r.reasons.any((x) => x.code == 'marine_severe'), true);
  });

  test('missing weather → insufficientData', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: null,
        weatherError: 'timeout',
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.insufficientData);
    expect(r.reasons.any((x) => x.code == 'weather_missing'), true);
  });

  test('missing weather but marine noGo → noGo', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(marineZoneId: 'PZZ210'),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: null,
        marine: MarineSummary(
          zoneId: 'PZZ210',
          periods: [
            MarinePeriod(
              name: 'Today',
              detailedForecast: 'Hurricane warning conditions.',
            ),
          ],
        ),
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.noGo);
  });

  test('cfs above willamette noGo band → noGo', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(river: RiverSystem.willamette),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: _wx(speed: 5, gust: 5),
        riverFlow: RiverFlowReading(
          siteId: '14211720',
          cfs: 40000,
          observedAt: DateTime.now(),
        ),
      ),
      now: DateTime.parse('2026-06-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.noGo);
    expect(r.reasons.any((x) => x.code == 'flow_very_high'), true);
  });

  test('cold season adds info reason', () {
    final r = GoNoGoEvaluator.evaluate(
      _launch(),
      ConditionsSnapshot(
        fetchedAt: DateTime.now(),
        weather: _wx(speed: 5, gust: 5),
      ),
      now: DateTime.parse('2026-01-15T12:00:00-07:00'),
    );
    expect(r.verdict, GoNoGoVerdict.go);
    expect(r.reasons.any((x) => x.code == 'cold_water_season'), true);
  });
}
