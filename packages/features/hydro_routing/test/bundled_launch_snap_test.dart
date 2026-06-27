import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

/// Catalog launches documented as beyond [kReachabilitySnapMaxMeters] until a
/// geometry pass lands (see README-hydro.md).
const _knownUnsnappedLaunchIds = {
  'washougal_waterfront',
  'port_of_camas',
  'scappoose_bay_marina',
};

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
        if (_knownUnsnappedLaunchIds.contains(launch.id)) {
          continue;
        }

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
