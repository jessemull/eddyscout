import 'package:dio/dio.dart';
import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/main.dart';
import 'package:eddyscout/routing/saved_routes_database_override.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
const _integrationMapStub = bool.fromEnvironment('INTEGRATION_MAP_STUB');

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

/// HTTP-free conditions for any launch (avoids family override mismatches).
class IntegrationConditionsRepository implements ConditionsRepository {
  const IntegrationConditionsRepository();

  @override
  FutureResult<ConditionsSnapshot, AppFailure> load(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  }) async => Result.success(integrationCalmConditionsSnapshot());
}

/// Shared overrides mirroring [main] plus deterministic conditions for E2E.
Future<ProviderContainer> createIntegrationContainer({
  List<Override> extraOverrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final store = await SharedPreferencesKeyValueStore.open();

  final overrides =
      buildAppProviderOverrides(
        keyValueStore: store,
        conditionReportsRepository:
            const IntegrationConditionReportsRepository(),
        conditionsRepository: const IntegrationConditionsRepository(),
        mapboxTokenOverride: _mapboxAccessToken.isNotEmpty
            ? _mapboxAccessToken
            : null,
      )..addAll([
        savedRoutesDatabaseTestOverride(),
        launchPointLookupProvider.overrideWithValue(findLaunchPointById),
      ]);
  if (_integrationMapStub) {
    overrides.add(mapInteractiveProvider.overrideWithValue(true));
  }

  return ProviderContainer(overrides: [...overrides, ...extraOverrides]);
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
