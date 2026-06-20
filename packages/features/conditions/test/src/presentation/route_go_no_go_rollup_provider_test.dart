import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_launches.dart';

class _MockConditionsRepository extends Mock implements ConditionsRepository {}

class _MockGoNoGoProfileRepository extends Mock
    implements GoNoGoProfileRepository {}

ConditionsSnapshot _calmSnapshot() => ConditionsSnapshot(
  fetchedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
  weather: WeatherConditions(
    temperatureF: 55,
    windSpeedMph: 5,
    windGustMph: 6,
    windDirection: 'N',
    shortForecast: 'Fair',
    periodStart: DateTime.parse('2026-06-15T12:00:00-07:00'),
    source: WeatherDataSource.nws,
  ),
);

ConditionsSnapshot _windySnapshot() => ConditionsSnapshot(
  fetchedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
  weather: WeatherConditions(
    temperatureF: 55,
    windSpeedMph: 8,
    windGustMph: 25,
    windDirection: 'N',
    shortForecast: 'Windy',
    periodStart: DateTime.parse('2026-06-15T12:00:00-07:00'),
    source: WeatherDataSource.nws,
  ),
);

void main() {
  late _MockConditionsRepository repository;
  late _MockGoNoGoProfileRepository profileRepository;

  setUpAll(() {
    registerFallbackValue(CancelToken());
    registerFallbackValue(GoNoGoProfile.intermediate);
  });

  setUp(() {
    repository = _MockConditionsRepository();
    profileRepository = _MockGoNoGoProfileRepository();
    when(() => profileRepository.read()).thenAnswer(
      (_) async => const Success(GoNoGoProfile.intermediate),
    );
  });

  test('rolls up worst verdict across waypoints', () async {
    when(
      () => repository.load(
        testCathedralParkLaunch,
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Success(_calmSnapshot()));
    when(
      () => repository.load(
        testKelleyPointLaunch,
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Success(_windySnapshot()));

    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      routeGoNoGoRollupProvider([
        testCathedralParkLaunch.id,
        testKelleyPointLaunch.id,
      ]).future,
    );

    expect(result.verdict, GoNoGoVerdict.noGo);
    expect(result.waypointResults.length, 2);
    expect(result.triggeringWaypoint?.launchId, testKelleyPointLaunch.id);
  });

  test('continues when one waypoint fetch fails', () async {
    when(
      () => repository.load(
        testCathedralParkLaunch,
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Success(_calmSnapshot()));
    when(
      () => repository.load(
        testKelleyPointLaunch,
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Failure(NetworkFailure(message: 'network down')),
    );

    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      routeGoNoGoRollupProvider([
        testCathedralParkLaunch.id,
        testKelleyPointLaunch.id,
      ]).future,
    );

    expect(result.verdict, GoNoGoVerdict.go);
    expect(result.waypointFailures.length, 1);
    expect(result.waypointResults.length, 1);
  });

  test('throws when fewer than two waypoints', () async {
    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(routeGoNoGoRollupProvider(['only_one']).future),
      throwsA(isA<UnexpectedFailure>()),
    );
  });
}
