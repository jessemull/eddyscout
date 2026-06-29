import 'dart:convert';
import 'dart:io';

import 'package:eddyscout_conditions/src/data/conditions_service.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements EddyScoutHttpClient {}

Map<String, dynamic> _fixture(String name) {
  final path = '${Directory.current.path}/test/fixtures/$name';
  final raw = File(path).readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.test'));
  });

  late _MockHttp http;
  late ConditionsService service;

  setUp(() {
    http = _MockHttp();
    service = ConditionsService(http);
    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(() => http.getJson(any())).thenAnswer((_) async => null);
  });

  test(
    'load returns snapshot with weather error when NWS points fail',
    () async {
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
      final snapshot = result.valueOrNull!;
      expect(snapshot.weather, isNull);
      expect(snapshot.weatherError, isNotNull);
    },
  );

  test('load returns weather from NWS hourly when available', () async {
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

    when(() => http.getNwsJson(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      if (uri.path.startsWith('/points/')) {
        return _fixture('nws_points.json');
      }
      if (uri.path.contains('/forecast/hourly')) {
        return _fixture('nws_hourly.json');
      }
      return null;
    });

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.weather, isNotNull);
    expect(snapshot.weather?.source, WeatherDataSource.nws);
    expect(snapshot.weatherError, isNull);
  });

  test('load falls back to Open-Meteo when NWS points fail', () async {
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

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.weather, isNotNull);
    expect(snapshot.weather?.source, WeatherDataSource.openMeteo);
  });

  test('load includes tide summary when launch has station id', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.minor,
      noaaTideStationId: '9439221',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));

    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      final datum = uri.queryParameters['datum'];
      if (datum == 'CRD') {
        return const EddyScoutHttpResponse(
          statusCode: 200,
          body: '{"error":"x"}',
        );
      }
      return EddyScoutHttpResponse(
        statusCode: 200,
        body: jsonEncode(_fixture('noaa_predictions.json')),
      );
    });

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.tides, isNotNull);
    expect(snapshot.tides?.events, isNotEmpty);
    expect(snapshot.tideError, isNull);
  });

  test('load sets tideError when NOAA request fails', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.minor,
      noaaTideStationId: '9439221',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));
    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer(
      (_) async => const EddyScoutHttpResponse(statusCode: 500, body: 'no'),
    );

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.tides, isNull);
    expect(snapshot.tideError, isNotNull);
  });

  test('load includes marine summary when launch has marine zone id', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.columbia,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      marineZoneId: 'PZZ210',
    );

    when(() => http.getNwsJson(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      if (uri.path.contains('/zones/marine/') &&
          uri.path.endsWith('/forecast')) {
        return _fixture('nws_marine.json');
      }
      return null;
    });
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.marine, isNotNull);
    expect(snapshot.marine?.periods, isNotEmpty);
    expect(snapshot.marineError, isNull);
  });

  test('load sets marineError when CWF fallback cannot load zone', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.columbia,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      marineZoneId: 'PZZ999',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.marine, isNull);
    expect(snapshot.marineError, isNotNull);
  });

  test('load includes river flow when launch has usgs site id', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      usgsSiteId: '14211720',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));
    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      if (uri.host.contains('waterservices.usgs.gov')) {
        return EddyScoutHttpResponse(
          statusCode: 200,
          body: jsonEncode(_fixture('usgs_iv.json')),
        );
      }
      return const EddyScoutHttpResponse(statusCode: 200, body: '{"ok":true}');
    });

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.riverFlow, isNotNull);
    expect(snapshot.riverFlow?.siteId, '14211720');
    expect(snapshot.riverError, isNull);
  });

  test('load sets riverError on non-2xx USGS response', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      usgsSiteId: '14211720',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));
    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer(
      (_) async => const EddyScoutHttpResponse(statusCode: 503, body: 'down'),
    );

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.riverFlow, isNull);
    expect(snapshot.riverError, isNotNull);
  });

  test('load sets riverError on unexpected USGS response shape', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      usgsSiteId: '14211720',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));
    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer(
      (_) async => const EddyScoutHttpResponse(statusCode: 200, body: '[]'),
    );

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.riverFlow, isNull);
    expect(snapshot.riverError, isNotNull);
  });

  test('load sets riverError when no discharge reading is present', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      usgsSiteId: '14211720',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));
    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer(
      (_) async => const EddyScoutHttpResponse(statusCode: 200, body: '{}'),
    );

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.riverFlow, isNull);
    expect(snapshot.riverError, isNotNull);
  });

  test('load sets tideError when predictions are empty', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.minor,
      noaaTideStationId: '9439221',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));
    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer(
      (_) async => const EddyScoutHttpResponse(
        statusCode: 200,
        body: '{"predictions":[]}',
      ),
    );

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    final snapshot = result.valueOrNull!;
    expect(snapshot.tides, isNull);
    expect(snapshot.tideError, isNotNull);
  });

  test('load falls back when NWS hourly request fails', () async {
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

    when(() => http.getNwsJson(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      if (uri.path.startsWith('/points/')) {
        return _fixture('nws_points.json');
      }
      return null;
    });
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.weather?.source, WeatherDataSource.openMeteo);
  });

  test('load sets riverError when USGS returns zero cfs', () async {
    const launch = LaunchPoint(
      id: 'test',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      usgsSiteId: '14211720',
    );

    when(() => http.getNwsJson(any())).thenAnswer((_) async => null);
    when(
      () => http.getJson(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => _fixture('open_meteo_current.json'));

    final json = Map<String, dynamic>.from(_fixture('usgs_iv.json'));
    final values =
        (json['value'] as Map<String, dynamic>)['timeSeries'] as List<dynamic>;
    final block =
        (values.first as Map<String, dynamic>)['values'] as List<dynamic>;
    final inner =
        (block.first as Map<String, dynamic>)['value'] as List<dynamic>;
    (inner.last as Map<String, dynamic>)['value'] = '0';

    when(
      () => http.get(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer(
      (_) async => EddyScoutHttpResponse(
        statusCode: 200,
        body: jsonEncode(json),
      ),
    );

    final result = await service.load(launch);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.riverFlow, isNull);
    expect(result.valueOrNull!.riverError, isNotNull);
  });
}
