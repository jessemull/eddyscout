import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

void main() {
  group('bundled launch snap coverage', () {
    test('catalog launches snap within reachability threshold', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final bridges = await readBundledConfluenceBridgesJson();
      final planner = RiverRoutePlanner.fromGeoJsonDocuments(
        docs,
        confluenceBridgesJson: bridges,
      );

      for (final launch in kLaunchPoints) {
        expect(
          planner.validateLaunchSnap(launch),
          isNull,
          reason:
              '${launch.id} (${launch.riverSystem.name}) is farther than '
              '${kReachabilitySnapMaxMeters.toInt()} m from bundled geometry',
        );
      }
    });
  });
}
