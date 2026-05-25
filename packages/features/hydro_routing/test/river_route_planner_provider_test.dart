import 'dart:io';

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
  });
}
