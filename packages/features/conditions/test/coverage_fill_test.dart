import 'package:eddyscout_conditions/src/data/parsing/noaa_tides_json.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('conditions_models fromJson', () {
    test('WeatherConditions.fromJson parses', () {
      final w = WeatherConditions.fromJson(<String, dynamic>{
        'source': 'nws',
        'temperatureF': 60,
        'windSpeedMph': 5,
        'windGustMph': 9,
        'windDirection': 'W',
        'shortForecast': 'Ok',
        'periodStart': '2026-01-01T00:00:00.000Z',
      });
      expect(w.source, WeatherDataSource.nws);
      expect(w.temperatureF, 60);
    });

    test('ConditionsSnapshot.fromJson parses partial snapshot', () {
      final s = ConditionsSnapshot.fromJson(<String, dynamic>{
        'fetchedAt': '2026-01-01T00:00:00.000Z',
        'weatherError': 'x',
      });
      expect(s.weather, isNull);
      expect(s.weatherError, 'x');
    });

    test('other model fromJson factories are callable', () {
      final tide = TideEvent.fromJson(<String, dynamic>{
        'type': 'H',
        'time': '2026-01-01T00:00:00.000Z',
        'heightFt': 2.5,
      });
      expect(tide.type, 'H');

      final tideSummary = TideSummary.fromJson(<String, dynamic>{
        'stationId': 's',
        'datumLabel': 'MLLW',
        'events': [
          <String, dynamic>{
            'type': 'L',
            'time': '2026-01-01T01:00:00.000Z',
            'heightFt': 0.1,
          },
        ],
        'referenceNote': 'note',
      });
      expect(tideSummary.stationId, 's');

      final marine = MarineSummary.fromJson(<String, dynamic>{
        'zoneId': 'PZZ210',
        'periods': [
          <String, dynamic>{'name': 'Today', 'detailedForecast': 'Calm.'},
        ],
      });
      expect(marine.zoneId, 'PZZ210');

      final flow = RiverFlowReading.fromJson(<String, dynamic>{
        'siteId': '14211720',
        'cfs': 123.0,
        'observedAt': '2026-01-01T00:00:00.000Z',
      });
      expect(flow.cfs, 123);
    });
  });

  group('noaa_tides_json edge cases', () {
    test('tidesFromNoaaPredictions returns null when predictions missing', () {
      final t = tidesFromNoaaPredictions(
        const <String, dynamic>{},
        stationId: 's',
        datumLabel: 'd',
      );
      expect(t, isNull);
    });

    test(
      'tidesFromNoaaPredictions returns null when events are unparseable',
      () {
        final t = tidesFromNoaaPredictions(
          <String, dynamic>{
            'predictions': [
              {'t': 'not-a-time', 'v': 'x', 'type': 'H'},
            ],
          },
          stationId: 's',
          datumLabel: 'd',
        );
        expect(t, isNull);
      },
    );
  });

  group('GoNoGoEvaluator additional branches', () {
    test('missing weather with explicit weatherError stores error param', () {
      const launch = LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );
      final snapshot = ConditionsSnapshot(
        fetchedAt: DateTime(2026),
        weatherError: 'weather_nws_error',
      );
      final result = GoNoGoEvaluator.evaluate(
        launch,
        snapshot,
        now: DateTime(2026, 6, 1),
      );
      expect(
        result.reasons.any((r) => r.code == GoNoGoReasonCode.weatherMissing),
        isTrue,
      );
      expect(
        result.reasons
            .firstWhere((r) => r.code == GoNoGoReasonCode.weatherMissing)
            .weatherError,
        'weather_nws_error',
      );
    });

    test('forecast time info is not added for daytime', () {
      const launch = LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );
      final snapshot = ConditionsSnapshot(
        fetchedAt: DateTime(2026),
        weather: WeatherConditions(
          source: WeatherDataSource.nws,
          windSpeedMph: 3,
          periodStart: DateTime(2026, 6, 1, 12),
        ),
      );
      final result = GoNoGoEvaluator.evaluate(
        launch,
        snapshot,
        now: DateTime(2026, 6, 1),
      );
      expect(
        result.reasons.any(
          (r) => r.code == GoNoGoReasonCode.forecastLowLightHours,
        ),
        isFalse,
      );
    });
  });
}
