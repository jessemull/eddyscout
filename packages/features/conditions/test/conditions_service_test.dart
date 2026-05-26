import 'package:eddyscout_conditions/src/data/conditions_service.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements EddyScoutHttpClient {}

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
}
