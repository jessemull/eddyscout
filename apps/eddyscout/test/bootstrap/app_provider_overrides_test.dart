import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/eddyscout_map_data.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
  });

  test('buildAppProviderOverrides wires core repository tokens', () async {
    final container = ProviderContainer(
      overrides: buildAppProviderOverrides(keyValueStore: store),
    );
    addTearDown(container.dispose);

    expect(container.read(conditionsRepositoryProvider), isNotNull);
    expect(container.read(conditionReportsRepositoryProvider), isNotNull);
    expect(container.read(conditionsAiSummaryRepositoryProvider), isNotNull);
    expect(container.read(conditionReportSubmitRepositoryProvider), isNotNull);
    expect(container.read(goNoGoProfileRepositoryProvider), isNotNull);
    expect(container.read(gpxFileGatewayProvider), isA<GpxFileGatewayImpl>());
    expect(
      await container.read(mapKeyValueStoreProvider.future),
      same(store),
    );
    expect(
      await container.read(userPreferencesKeyValueStoreProvider.future),
      same(store),
    );
  });

  test('buildAppProviderOverrides applies optional map overrides', () {
    final overrides = buildAppProviderOverrides(
      keyValueStore: store,
      mapboxTokenOverride: 'pk.test',
      mapInteractiveOverride: false,
    );
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);

    expect(container.read(mapboxAccessTokenProvider), 'pk.test');
    expect(container.read(mapInteractiveProvider), isFalse);
  });

  test(
    'hydroGeoJsonLoaderProvider loads all bundled hydro assets',
    () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final docs = await container.read(hydroGeoJsonLoaderProvider)();
      expect(docs, hasLength(7));
      expect(docs.first, contains('FeatureCollection'));
      expect(docs.first, contains('willamette'));
      expect(
        docs.any((doc) => doc.contains('columbia_lower')),
        isTrue,
      );
    },
  );

  test(
    'riverRoutePlannerProvider routes same-system launches on unified graph',
    () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final planner = await container.read(riverRoutePlannerProvider.future);
      final putIn = LaunchPoint(
        id: 'cathedral_park',
        name: 'Cathedral Park',
        latitude: 45.5621,
        longitude: -122.7328,
        shortNote: 'Test',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );
      final takeOut = LaunchPoint(
        id: 'sellwood_riverfront',
        name: 'Sellwood',
        latitude: 45.4709,
        longitude: -122.6617,
        shortNote: 'Test',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );
      expect(planner.plan(putIn, takeOut), isA<RouteSuccess>());
    },
  );

  test(
    'riverRoutePlannerProvider routes cross-system launches on unified graph',
    () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final planner = await container.read(riverRoutePlannerProvider.future);
      final putIn = LaunchPoint(
        id: 'cathedral_park',
        name: 'Cathedral Park',
        latitude: 45.5621,
        longitude: -122.7328,
        shortNote: 'Test',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );
      final takeOut = LaunchPoint(
        id: 'glenn_otto_troutdale',
        name: 'Glenn Otto Park',
        latitude: 45.5365,
        longitude: -122.3858,
        shortNote: 'Test',
        riverSystem: RiverSystem.columbia,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );
      expect(planner.plan(putIn, takeOut), isA<RouteSuccess>());
    },
  );

  test(
    'mapGpxServiceProvider resolves from app overrides',
    () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final service = await container.read(mapGpxServiceProvider.future);
      expect(service, isA<MapGpxService>());
    },
  );

  test(
    'mapRoutePlannerProvider resolves after hydro graphs load',
    () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final planner = await container.read(mapRoutePlannerProvider.future);
      expect(planner, isA<MapRoutePlanner>());
    },
  );

  test('routesProvider override is supplied for goRouterProvider', () {
    final container = ProviderContainer(
      overrides: buildAppProviderOverrides(keyValueStore: store),
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(routesProvider),
      returnsNormally,
    );
  });

  test(
    'launchSuggestedTripsIndexLoaderProvider loads bundled asset',
    () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final raw = await container.read(
        launchSuggestedTripsIndexLoaderProvider,
      )();
      expect(raw, contains('"schemaVersion"'));
      expect(raw, contains('"oneWay"'));
    },
  );
}
