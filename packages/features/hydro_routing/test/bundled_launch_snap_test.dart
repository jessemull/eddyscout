import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

void main() {
  group('bundled launch snap coverage', () {
    test('catalog water-entry coords snap within quality threshold', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final bridges = await readBundledConfluenceBridgesJson();
      final planner = RiverRoutePlanner.fromGeoJsonDocuments(
        docs,
        confluenceBridgesJson: bridges,
      );
      final graph = planner.graphForTesting;

      for (final launch in kLaunchPoints) {
        final snap = graph.snapToVertex(
          launch.routingLatitude,
          launch.routingLongitude,
          maxSnapMeters: kCatalogWaterEntrySnapMaxMeters,
        );
        expect(
          snap?.snapMeters,
          lessThanOrEqualTo(kCatalogWaterEntrySnapMaxMeters),
          reason:
              '${launch.id} (${launch.riverSystem.name}) water entry is '
              'farther than ${kCatalogWaterEntrySnapMaxMeters.toInt()} m '
              'from bundled geometry',
        );
      }
    });

    test(
      'catalog launches validate for routing at reachability threshold',
      () async {
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
                '${launch.id} (${launch.riverSystem.name}) is not routable at '
                '${kReachabilitySnapMaxMeters.toInt()} m snap tolerance',
          );
        }
      },
    );
  });
}
