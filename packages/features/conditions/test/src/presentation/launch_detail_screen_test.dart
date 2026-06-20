import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/eddyscout_conditions_data.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_launches.dart';
import '../../helpers/test_localized_app.dart';

class _MockConditionsAiSummaryRepository extends Mock
    implements ConditionsAiSummaryRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockConditionsAiSummaryRepository aiSummaryRepository;

  setUpAll(() {
    registerFallbackValue(CancelToken());
    registerFallbackValue(testCathedralParkLaunch);
    registerFallbackValue(
      ConditionsSnapshot(fetchedAt: DateTime.utc(2026, 6, 15, 12)),
    );
    registerFallbackValue(
      GoNoGoResult(
        verdict: GoNoGoVerdict.go,
        reasons: const [],
        computedAt: DateTime.utc(2026, 6, 15, 12),
      ),
    );
    registerFallbackValue(GoNoGoProfile.intermediate);
  });

  setUp(() {
    aiSummaryRepository = _MockConditionsAiSummaryRepository();
    when(
      () => aiSummaryRepository.summarize(
        launch: any(named: 'launch'),
        snapshot: any(named: 'snapshot'),
        goNoGo: any(named: 'goNoGo'),
        skillProfile: any(named: 'skillProfile'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => const Result.success('Calm afternoon paddle.'));
  });

  final launch = testCathedralParkLaunch;
  final kelleyPoint = testKelleyPointLaunch;

  ConditionsSnapshot calmSnapshot({WeatherConditions? weather}) {
    return ConditionsSnapshot(
      fetchedAt: DateTime.utc(2026, 6, 15, 12),
      weather:
          weather ??
          const WeatherConditions(
            source: WeatherDataSource.nws,
            windSpeedMph: 5,
            windDirection: 'N',
            shortForecast: 'Light wind',
          ),
    );
  }

  ConditionsSnapshot richSnapshot({required LaunchPoint forLaunch}) {
    return ConditionsSnapshot(
      fetchedAt: DateTime.utc(2026, 6, 15, 12),
      weather: const WeatherConditions(
        source: WeatherDataSource.openMeteo,
        windSpeedMph: 12,
        windGustMph: 18,
        windDirection: 'SW',
        shortForecast: 'Breezy',
        temperatureF: 62,
      ),
      riverFlow: RiverFlowReading(
        siteId: forLaunch.usgsSiteId ?? '14211720',
        cfs: 12_345,
        observedAt: DateTime.utc(2026, 6, 15, 11),
      ),
      tides: TideSummary(
        stationId: forLaunch.noaaTideStationId ?? '9440083',
        datumLabel: 'MLLW',
        events: [
          TideEvent(
            type: 'H',
            time: DateTime.utc(2026, 6, 15, 14),
            heightFt: 1.2,
          ),
        ],
        referenceNote: 'Pool stage reference',
      ),
      marine: forLaunch.marineZoneId == null
          ? null
          : MarineSummary(
              zoneId: forLaunch.marineZoneId!,
              periods: const [
                MarinePeriod(
                  name: 'Today',
                  detailedForecast: 'Small craft advisory in effect.',
                ),
              ],
            ),
    );
  }

  Future<ProviderContainer> scopedContainer({
    required Future<ConditionsSnapshot> Function() loadConditions,
    LaunchPoint? launchPoint,
    List<Override> extraOverrides = const [],
  }) async {
    final activeLaunch = launchPoint ?? launch;
    SharedPreferences.setMockInitialValues({});
    final store = await SharedPreferencesKeyValueStore.open();
    return ProviderContainer(
      overrides: [
        goNoGoProfileRepositoryProvider.overrideWithValue(
          GoNoGoProfileRepositoryImpl(store),
        ),
        conditionsAiSummaryRepositoryProvider.overrideWithValue(
          aiSummaryRepository,
        ),
        conditionReportSubmitRepositoryProvider.overrideWithValue(
          const ConditionReportSubmitRepositoryImpl(),
        ),
        conditionsSnapshotProvider(activeLaunch).overrideWith(
          (ref) => loadConditions(),
        ),
        ...extraOverrides,
      ],
    );
  }

  Future<void> pumpLaunchDetail(
    WidgetTester tester, {
    required ProviderContainer container,
    LaunchPoint? launchPoint,
  }) async {
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: LaunchDetailScreen(launch: launchPoint ?? launch),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows loading indicator while conditions load', (tester) async {
    final container = await scopedContainer(
      loadConditions: () => Completer<ConditionsSnapshot>().future,
    );
    await pumpLaunchDetail(tester, container: container);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(launch.name), findsOneWidget);
  });

  testWidgets('shows friendly error when conditions fail', (tester) async {
    final container = await scopedContainer(
      loadConditions: () async {
        throw const NetworkFailure(message: 'Could not reach the service.');
      },
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Could not reach'), findsOneWidget);
  });

  testWidgets('shows go/no-go card and weather when data loads', (
    tester,
  ) async {
    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pump();

    expect(find.text('Go / No-go (informational)'), findsOneWidget);
    expect(find.text('Go (planning hint)'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Conditions'), findsOneWidget);
    expect(find.text(launch.shortNote), findsOneWidget);
  });

  testWidgets('shows unauthenticated hint when recent reports fail', (
    tester,
  ) async {
    FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
    addTearDown(FirebaseFlagsTestHooks.reset);
    expect(firebaseCallablesAvailable, isTrue);

    const unauthMessage =
        'Authentication required (unauthenticated). Restart the app.';

    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
      extraOverrides: [
        conditionReportsListProvider(launch.id).overrideWith(
          (ref) async {
            throw const NetworkFailure(message: unauthMessage);
          },
        ),
      ],
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    final reportsError = find.textContaining('Could not load reports');
    await tester.scrollUntilVisible(reportsError, 200);

    expect(find.textContaining('unauthenticated'), findsOneWidget);
    expect(find.textContaining('fully stop the app'), findsOneWidget);
  });

  testWidgets('shows river, tide, and marine cards for rich snapshot', (
    tester,
  ) async {
    final container = await scopedContainer(
      launchPoint: kelleyPoint,
      loadConditions: () => Future.value(richSnapshot(forLaunch: kelleyPoint)),
    );
    await pumpLaunchDetail(
      tester,
      container: container,
      launchPoint: kelleyPoint,
    );
    await tester.pumpAndSettle();

    final riverTitle = find.text('River flow (USGS)');
    await tester.scrollUntilVisible(riverTitle, 200);
    expect(riverTitle, findsOneWidget);

    final tidesTitle = find.descendant(
      of: find.byType(Card),
      matching: find.text('Tides'),
    );
    await tester.scrollUntilVisible(tidesTitle, 200);
    expect(tidesTitle, findsOneWidget);

    final marineTitle = find.textContaining('Marine (NWS PZZ210)');
    await tester.scrollUntilVisible(marineTitle, 200);
    expect(marineTitle, findsOneWidget);

    await tester.tap(marineTitle);
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(
      find.text('Small craft advisory in effect.'),
      findsOneWidget,
    );
  });

  testWidgets('shows weather unavailable when weather fetch failed', (
    tester,
  ) async {
    final container = await scopedContainer(
      loadConditions: () => Future.value(
        ConditionsSnapshot(
          fetchedAt: DateTime.utc(2026, 6, 15, 12),
          weatherError: 'weather_nws_error',
        ),
      ),
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets('updates skill profile when segmented control changes', (
    tester,
  ) async {
    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();

    expect(
      container.read(goNoGoProfileProvider).value,
      GoNoGoProfile.advanced,
    );
  });

  testWidgets(
    'shows Firebase cards and empty reports when callables available',
    (
      tester,
    ) async {
      FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
      addTearDown(FirebaseFlagsTestHooks.reset);

      final container = await scopedContainer(
        loadConditions: () => Future.value(calmSnapshot()),
        extraOverrides: [
          conditionReportsListProvider(launch.id).overrideWith(
            (ref) async => const <ConditionReportListItem>[],
          ),
        ],
      );
      await pumpLaunchDetail(tester, container: container);
      await tester.pumpAndSettle();

      for (final label in [
        'Summarize with AI',
        'Summarize recent reports',
        'Report conditions',
        'No paddler reports yet.',
      ]) {
        await tester.scrollUntilVisible(find.text(label), 200);
        expect(find.text(label), findsOneWidget);
      }
    },
  );

  testWidgets('shows recent report tiles when list has items', (
    tester,
  ) async {
    FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
    addTearDown(FirebaseFlagsTestHooks.reset);

    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
      extraOverrides: [
        conditionReportsListProvider(launch.id).overrideWith(
          (ref) async => [
            ConditionReportListItem(
              message: 'Choppy near the bridge',
              createdAt: DateTime.utc(2026, 6, 14, 10),
              isMine: true,
            ),
          ],
        ),
      ],
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    final reportText = find.text('Choppy near the bridge');
    await tester.scrollUntilVisible(reportText, 200);

    expect(find.textContaining('You'), findsOneWidget);
    expect(reportText, findsOneWidget);
  });

  testWidgets('shows go/no-go reasons for windy conditions', (tester) async {
    final container = await scopedContainer(
      loadConditions: () => Future.value(
        calmSnapshot(
          weather: const WeatherConditions(
            source: WeatherDataSource.nws,
            windSpeedMph: 28,
            windDirection: 'W',
            shortForecast: 'Very windy',
          ),
        ),
      ),
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data == 'No-go (planning hint)' ||
                widget.data == 'Marginal'),
      ),
      findsOneWidget,
    );
    expect(find.text('•'), findsWidgets);
    expect(find.textContaining('Effective wind about'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && (widget.data?.contains('wind_high') ?? false),
      ),
      findsNothing,
    );
  });

  testWidgets('starts AI summary when summarize button is tapped', (
    tester,
  ) async {
    FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
    addTearDown(FirebaseFlagsTestHooks.reset);

    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
      extraOverrides: [
        conditionReportsListProvider(launch.id).overrideWith(
          (ref) async => const <ConditionReportListItem>[],
        ),
      ],
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    final summarizeButton = find.text('Summarize with AI');
    await tester.scrollUntilVisible(summarizeButton, 200);
    await tester.tap(summarizeButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(summarizeButton, findsNothing);
  });

  testWidgets('shows river flow error message when gauge data missing', (
    tester,
  ) async {
    final container = await scopedContainer(
      loadConditions: () => Future.value(
        ConditionsSnapshot(
          fetchedAt: DateTime.utc(2026, 6, 15, 12),
          weather: calmSnapshot().weather,
          riverError: 'river_no_discharge_now',
        ),
      ),
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    final riverTitle = find.text('River flow (USGS)');
    await tester.scrollUntilVisible(riverTitle, 200);

    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('shows generic conditions error for socket failures', (
    tester,
  ) async {
    final container = await scopedContainer(
      loadConditions: () async {
        throw Exception('SocketException: connection failed');
      },
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pump();
    await tester.pump();

    expect(
      find.textContaining('Could not load conditions'),
      findsOneWidget,
    );
  });

  testWidgets('opens condition report sheet from list tile', (tester) async {
    FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
    addTearDown(FirebaseFlagsTestHooks.reset);

    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
      extraOverrides: [
        conditionReportsListProvider(launch.id).overrideWith(
          (ref) async => const <ConditionReportListItem>[],
        ),
      ],
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pumpAndSettle();

    final reportTile = find.text('Report conditions');
    await tester.scrollUntilVisible(reportTile, 200);
    await tester.tap(reportTile);
    await tester.pumpAndSettle();

    expect(find.text('Condition report'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('renders optional trips-from-here section when provided', (
    tester,
  ) async {
    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: LaunchDetailScreen(
            launch: launch,
            tripsFromHereSection: const Text('Trips from here slot'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trips from here slot'), findsOneWidget);
  });
}
