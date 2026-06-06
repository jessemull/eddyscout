import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> _loadFixtureHydroGeoJson() async {
  return File('test/fixtures/willamette_waterway.geojson').readAsString();
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
            () async => '{"type":"Point"}',
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
            () async => 'not json',
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
