import 'dart:io';

import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

String _loadBundledHydroGeoJson() {
  final path =
      '${Directory.current.path}/../../../apps/eddyscout/assets/hydro/willamette_waterway.geojson';
  return File(path).readAsStringSync();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('riverRoutePlannerProvider', () {
    test('loads bundled hydro geojson', () async {
      final container = ProviderContainer(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            () async => _loadBundledHydroGeoJson(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final planner = await container.read(riverRoutePlannerProvider.future);

      expect(planner, isNotNull);
    });
  });
}
