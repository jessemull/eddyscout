import 'package:eddyscout_conditions/src/data/conditions_http_provider.dart';
import 'package:eddyscout_conditions/src/data/conditions_service.dart';
import 'package:eddyscout_conditions/src/data/conditions_service_provider.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_summary_payload.dart';
import 'package:eddyscout_conditions/src/data/parsing/noaa_tides_json.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/conditions_repository_provider.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go_thresholds.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements EddyScoutHttpClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.test'));
  });

  group('conditions service buffer', () {
    late _MockHttp http;
    late ConditionsService service;

    setUp(() {
      http = _MockHttp();
      service = ConditionsService(http);
      when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
      when(() => http.getJson(any())).thenAnswer((_) async => null);
    });

    test('load maps uncaught errors to failure', () async {
      when(
        () => http.getNwsJson(any(), cancelToken: any(named: 'cancelToken')),
      ).thenThrow(StateError('boom'));

      const launch = LaunchPoint(
        id: 'test',
        name: 'Test',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final result = await service.load(launch);
      expect(result.isFailure, isTrue);
    });

    test('load returns snapshot on success via Result', () async {
      when(
        () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async => {
          'current': {
            'temperature_2m': 60,
            'wind_speed_10m': 5,
            'wind_gusts_10m': 8,
            'wind_direction_10m': 180,
          },
        },
      );

      const launch = LaunchPoint(
        id: 'test',
        name: 'Test',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final result = await service.load(launch);
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.weather, isNotNull);
    });

    test('load returns failure on unexpected error', () async {
      when(
        () => http.getNwsJson(any(), cancelToken: any(named: 'cancelToken')),
      ).thenThrow(StateError('boom'));

      const launch = LaunchPoint(
        id: 'test',
        name: 'Test',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final result = await service.load(launch);
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<AppFailure>());
    });

    test('NWS hourly URL missing falls back to Open-Meteo', () async {
      when(() => http.getNwsJson(any())).thenAnswer(
        (_) async => <String, dynamic>{'properties': <String, dynamic>{}},
      );
      when(
        () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async => {
          'current': {
            'temperature_2m': 60,
            'wind_speed_10m': 5,
            'wind_gusts_10m': 8,
            'wind_direction_10m': 180,
          },
        },
      );

      const launch = LaunchPoint(
        id: 'test',
        name: 'Test',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final result = await service.load(launch);
      expect(result.valueOrNull?.weather?.source, WeatherDataSource.openMeteo);
    });

    test('NWS exception with failed Open-Meteo uses fallback code', () async {
      when(
        () => http.getNwsJson(any(), cancelToken: any(named: 'cancelToken')),
      ).thenThrow(Exception('nws down'));
      when(
        () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
      ).thenThrow(Exception('meteo down'));

      const launch = LaunchPoint(
        id: 'test',
        name: 'Test',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final result = await service.load(launch);
      expect(result.valueOrNull?.weather, isNull);
      expect(result.valueOrNull?.weatherError, isNotNull);
    });
  });

  group('noaa_tides_json buffer', () {
    test('parses NOAA local datetime without T separator', () {
      final summary = tidesFromNoaaPredictions(
        <String, dynamic>{
          'predictions': [
            {'t': '2026-04-12 02:34', 'v': '2.1', 'type': 'H'},
          ],
        },
        stationId: 's',
        datumLabel: 'MLLW',
      );
      expect(summary, isNotNull);
      expect(summary!.events.single.type, 'H');
    });
  });

  group('go/no-go buffer', () {
    test('GoNoGoReason and GoNoGoResult fromJson round-trip', () {
      final reason = GoNoGoReason.fromJson(<String, dynamic>{
        'code': 'wind_high',
        'message': 'High wind',
        'severity': 'noGo',
      });
      expect(reason.code, 'wind_high');

      final result = GoNoGoResult.fromJson(<String, dynamic>{
        'verdict': 'go',
        'reasons': [
          <String, dynamic>{
            'code': 'wind_high',
            'message': 'High wind',
            'severity': 'noGo',
          },
        ],
        'computedAt': '2026-01-01T00:00:00.000Z',
      });
      expect(result.verdict, GoNoGoVerdict.go);
    });

    test('wind_unknown when speeds are missing', () {
      const launch = LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.exposed,
        tideRelevance: TideRelevance.none,
      );
      final result = GoNoGoEvaluator.evaluate(
        launch,
        ConditionsSnapshot(
          fetchedAt: DateTime(2026, 6, 1),
          weather: const WeatherConditions(source: WeatherDataSource.nws),
        ),
        now: DateTime(2026, 6, 1, 12),
      );
      expect(result.reasons.any((r) => r.code == 'wind_unknown'), isTrue);
    });

    test('marine text scan truncates very long forecasts', () {
      final longText = List.filled(200, 'gale').join(' ');
      final result = GoNoGoEvaluator.evaluate(
        LaunchPoint(
          id: 'id',
          name: 'n',
          latitude: 0,
          longitude: 0,
          shortNote: 'note',
          riverSystem: RiverSystem.willamette,
          windExposure: WindExposure.moderate,
          tideRelevance: TideRelevance.none,
          marineZoneId: 'PZZ210',
        ),
        ConditionsSnapshot(
          fetchedAt: DateTime(2026, 6, 1),
          weather: WeatherConditions(
            source: WeatherDataSource.nws,
            windSpeedMph: 5,
            windGustMph: 5,
            periodStart: DateTime(2026, 6, 1, 12),
          ),
          marine: MarineSummary(
            zoneId: 'PZZ210',
            periods: [
              MarinePeriod(name: 'Today', detailedForecast: longText),
            ],
          ),
        ),
        now: DateTime(2026, 6, 1, 12),
      );
      expect(result.reasons.any((r) => r.code.startsWith('marine_')), isTrue);
    });

    test('launch flowBands noGo threshold triggers flow_very_high', () {
      const bands = LaunchFlowBands(
        cfsMarginalBelow: 100,
        cfsComfortMax: 500,
        cfsNoGoAbove: 600,
      );
      final result = GoNoGoEvaluator.evaluate(
        LaunchPoint(
          id: 'id',
          name: 'n',
          latitude: 0,
          longitude: 0,
          shortNote: 'note',
          riverSystem: RiverSystem.willamette,
          windExposure: WindExposure.moderate,
          tideRelevance: TideRelevance.none,
          flowBands: bands,
        ),
        ConditionsSnapshot(
          fetchedAt: DateTime(2026, 6, 1),
          weather: WeatherConditions(
            source: WeatherDataSource.nws,
            windSpeedMph: 5,
            windGustMph: 5,
            periodStart: DateTime(2026, 6, 1, 12),
          ),
          riverFlow: RiverFlowReading(
            siteId: 'x',
            cfs: 700,
            observedAt: DateTime(2026, 6, 1),
          ),
        ),
        now: DateTime(2026, 6, 1, 12),
      );
      expect(result.reasons.any((r) => r.code == 'flow_very_high'), isTrue);
    });
  });

  group('river flow thresholds buffer', () {
    test('forRiverSystem covers columbia and slough', () {
      expect(
        RiverFlowThresholds.forRiverSystem(RiverSystem.columbia).noGoCfs,
        550000,
      );
      expect(
        RiverFlowThresholds.forRiverSystem(RiverSystem.slough).marginalCfs,
        22000,
      );
    });
  });

  group('conditions providers buffer', () {
    test('service and repository providers expose ConditionsService', () {
      final http = _MockHttp();
      final container = ProviderContainer(
        overrides: [
          conditionsHttpClientProvider.overrideWithValue(http),
          conditionsRepositoryProvider.overrideWith(
            (ref) => ref.watch(conditionsServiceProvider),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(conditionsServiceProvider),
        isA<ConditionsService>(),
      );
      expect(
        container.read(conditionsRepositoryProvider),
        same(container.read(conditionsServiceProvider)),
      );
    });
  });

  group('conditions summary payload buffer', () {
    test('LaunchSummary.fromJson parses', () {
      final summary = LaunchSummary.fromJson(<String, dynamic>{
        'id': 'id',
        'name': 'Name',
        'latitude': 1,
        'longitude': 2,
        'shortNote': 'note',
        'riverSystem': 'willamette',
        'windExposure': 'sheltered',
        'tideRelevance': 'none',
        'skillProfile': 'intermediate',
      });
      expect(summary.id, 'id');
    });
  });
}
