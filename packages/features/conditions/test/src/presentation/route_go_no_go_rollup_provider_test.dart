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

RouteGoNoGoWaypointsKey _waypointsKey(List<String> launchIds) {
  return RouteGoNoGoWaypointsKey.fromOrdered(launchIds);
}

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
    registerFallbackValue(testCathedralParkLaunch);
  });

  setUp(() {
    repository = _MockConditionsRepository();
    profileRepository = _MockGoNoGoProfileRepository();
    when(() => profileRepository.read()).thenAnswer(
      (_) async => const Success(GoNoGoProfile.intermediate),
    );
  });

  void stubLoad({
    required Future<Result<ConditionsSnapshot, AppFailure>> Function(
      LaunchPoint launch,
    )
    onLoad,
  }) {
    when(
      () => repository.load(
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((invocation) {
      final launch = invocation.positionalArguments[0] as LaunchPoint;
      return onLoad(launch);
    });
  }

  test('rolls up worst verdict across waypoints', () async {
    stubLoad(
      onLoad: (launch) async => switch (launch.id) {
        'cathedral_park' => Success(_calmSnapshot()),
        'kelley_point' => Success(_windySnapshot()),
        _ => Failure(UnexpectedFailure(message: 'unexpected ${launch.id}')),
      },
    );

    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      routeGoNoGoRollupProvider(
        _waypointsKey([
          testCathedralParkLaunch.id,
          testKelleyPointLaunch.id,
        ]),
      ).future,
    );

    expect(result.verdict, GoNoGoVerdict.noGo);
    expect(result.waypointResults.length, 2);
    expect(result.triggeringWaypoint?.launchId, testKelleyPointLaunch.id);
  });

  test('continues when one waypoint fetch fails', () async {
    stubLoad(
      onLoad: (launch) async => switch (launch.id) {
        'cathedral_park' => Success(_calmSnapshot()),
        'kelley_point' => Failure(NetworkFailure(message: 'network down')),
        _ => Failure(UnexpectedFailure(message: 'unexpected ${launch.id}')),
      },
    );

    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      routeGoNoGoRollupProvider(
        _waypointsKey([
          testCathedralParkLaunch.id,
          testKelleyPointLaunch.id,
        ]),
      ).future,
    );

    expect(result.verdict, GoNoGoVerdict.go);
    expect(result.waypointFailures.length, 1);
    expect(result.waypointResults.length, 1);
  });

  test('throws when all waypoint fetches fail', () async {
    stubLoad(
      onLoad: (_) async => Failure(NetworkFailure(message: 'network down')),
    );

    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(
        routeGoNoGoRollupProvider(
          _waypointsKey([
            testCathedralParkLaunch.id,
            testKelleyPointLaunch.id,
          ]),
        ).future,
      ),
      throwsA(isA<UnexpectedFailure>()),
    );
  });

  test('records unknown launch id in waypointFailures', () async {
    stubLoad(
      onLoad: (launch) async => switch (launch.id) {
        'cathedral_park' => Success(_calmSnapshot()),
        _ => Failure(UnexpectedFailure(message: 'unexpected ${launch.id}')),
      },
    );

    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    const unknownLaunchId = 'unknown_launch_id';
    final result = await container.read(
      routeGoNoGoRollupProvider(
        _waypointsKey([
          testCathedralParkLaunch.id,
          unknownLaunchId,
        ]),
      ).future,
    );

    expect(result.verdict, GoNoGoVerdict.go);
    expect(result.waypointResults.length, 1);
    expect(result.waypointFailures.length, 1);
    expect(result.waypointFailures.single.launchId, unknownLaunchId);
    expect(result.waypointFailures.single.failure, isA<NotFoundFailure>());
  });

  test('uses value equality for waypoints key across list instances', () async {
    var loadCount = 0;
    when(
      () => repository.load(
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async {
      loadCount++;
      return Success(_calmSnapshot());
    });

    final container = ProviderContainer(
      overrides: [
        conditionsRepositoryProvider.overrideWithValue(repository),
        goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);

    final launchIds = [
      testCathedralParkLaunch.id,
      testKelleyPointLaunch.id,
    ];
    final keyA = _waypointsKey(launchIds);
    final keyB = _waypointsKey(List<String>.of(launchIds));

    await container.read(routeGoNoGoRollupProvider(keyA).future);
    expect(loadCount, 2);

    await container.read(routeGoNoGoRollupProvider(keyB).future);
    expect(loadCount, 2);
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
      container.read(
        routeGoNoGoRollupProvider(_waypointsKey(['only_one'])).future,
      ),
      throwsA(isA<UnexpectedFailure>()),
    );
  });
}
