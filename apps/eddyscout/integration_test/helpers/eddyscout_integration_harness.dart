import 'package:dio/dio.dart';
import 'package:eddyscout/main.dart';
import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ensures the integration test binding is initialized once per suite.
void ensureIntegrationTestInitialized() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

ConditionsSnapshot integrationCalmConditionsSnapshot({
  WeatherConditions? weather,
}) => ConditionsSnapshot(
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

/// Deterministic reports repository — no Firebase callables in E2E.
class IntegrationConditionReportsRepository
    implements ConditionReportsRepository {
  const IntegrationConditionReportsRepository();

  @override
  FutureResult<List<ConditionReportListItem>, AppFailure> listReports(
    String launchId, {
    CancelToken? cancelToken,
  }) async => const Result.success(<ConditionReportListItem>[]);

  @override
  FutureResult<LaunchReportsDigestResult, AppFailure> summarizeLaunchReports({
    required String launchId,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async => const Result.success(
    LaunchReportsDigestResult(
      digestText: '',
      cached: false,
      noReports: true,
    ),
  );
}

/// Shared overrides mirroring [main] plus deterministic conditions for E2E.
Future<ProviderContainer> createIntegrationContainer({
  LaunchPoint? conditionsLaunch,
}) async {
  SharedPreferences.setMockInitialValues({});
  final store = await SharedPreferencesKeyValueStore.open();
  final launch =
      conditionsLaunch ??
      kLaunchPoints.firstWhere((launch) => launch.id == 'cathedral_park');

  return ProviderContainer(
    overrides: [
      conditionReportsRepositoryProvider.overrideWithValue(
        const IntegrationConditionReportsRepository(),
      ),
      hydroGeoJsonLoaderProvider.overrideWithValue(
        () => rootBundle.loadString('assets/hydro/willamette_waterway.geojson'),
      ),
      keyValueStoreProvider.overrideWith((ref) async => store),
      conditionsSnapshotProvider(launch).overrideWith(
        (ref) => Future.value(integrationCalmConditionsSnapshot()),
      ),
    ],
  );
}

/// Pumps [EddyScoutApp] with integration overrides; returns the container.
Future<ProviderContainer> pumpEddyScoutApp(
  WidgetTester tester, {
  ProviderContainer? container,
}) async {
  final scope = container ?? await createIntegrationContainer();
  addTearDown(scope.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child: const EddyScoutApp(),
    ),
  );
  return scope;
}
