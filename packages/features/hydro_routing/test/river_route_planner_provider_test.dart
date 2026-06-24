import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<String>> _loadFixtureHydroGeoJson() async {
  return [
    await File('test/fixtures/willamette_waterway.geojson').readAsString(),
    await File('test/fixtures/columbia_lower_waterway.geojson').readAsString(),
    await File('test/fixtures/columbia_gorge_waterway.geojson').readAsString(),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('riverRoutePlannerProvider', () {
    test('loads bundled hydro geojson', () async {
      final container = ProviderContainer(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            _loadFixtureHydroGeoJson,
          ),
        ],
      );
      addTearDown(container.dispose);

      final planner = await container.read(riverRoutePlannerProvider.future);

      expect(planner, isNotNull);
    });

    test('loads multiple river systems from merged assets', () async {
      final container = ProviderContainer(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            _loadFixtureHydroGeoJson,
          ),
        ],
      );
      addTearDown(container.dispose);

      final planner = await container.read(riverRoutePlannerProvider.future);
      final putIn = LaunchPoint(
        id: 'port_of_camas',
        name: 'Port of Camas Marina',
        latitude: 45.5856,
        longitude: -122.4244,
        shortNote: 'Test',
        riverSystem: RiverSystem.columbia,
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
    });

    test('routes cross-system launches from merged fixture assets', () async {
      final container = ProviderContainer(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            _loadFixtureHydroGeoJson,
          ),
        ],
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
    });

    test('surfaces loader failure as AppFailure', () async {
      final container = ProviderContainer(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            () async => throw Exception('asset missing'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(riverRoutePlannerProvider.future),
        throwsA(isA<HydroAppFailureException>()),
      );

      final async = container.read(riverRoutePlannerProvider);
      expect(async.hasError, isTrue);
      expect(hydroAppFailureFrom(async.error), isA<AssetLoadFailure>());
    });

    test('surfaces malformed GeoJSON as AppFailure', () async {
      final container = ProviderContainer(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            () async => ['{"type":"Point"}'],
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(riverRoutePlannerProvider.future),
        throwsA(isA<HydroAppFailureException>()),
      );

      final async = container.read(riverRoutePlannerProvider);
      expect(async.hasError, isTrue);
      expect(hydroAppFailureFrom(async.error), isA<ParseFailure>());
    });

    test('surfaces invalid JSON as AppFailure', () async {
      final container = ProviderContainer(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            () async => ['not json'],
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(riverRoutePlannerProvider.future),
        throwsA(isA<HydroAppFailureException>()),
      );

      final async = container.read(riverRoutePlannerProvider);
      expect(async.hasError, isTrue);
      expect(hydroAppFailureFrom(async.error), isA<ParseFailure>());
    });
  });
}
