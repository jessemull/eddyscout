import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

/// Catalog launches documented as beyond [kReachabilitySnapMaxMeters] until a
/// side-channel spur is added (see README-hydro.md).
const _knownUnsnappedLaunchIds = {
  'washougal_waterfront',
};

void main() {
  group('bundled launch snap coverage', () {
    test('catalog launches snap within reachability threshold', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final features = parseAndMergeHydroGeoJson(docs);
      final graphs = <String, RiverLineGraph>{};

      for (final system in RiverSystem.values) {
        final graph = RiverLineGraph.fromFeatures(
          features,
          riverSystemName: system.name,
        );
        if (graph.vertexCount > 0) {
          graphs[system.name] = graph;
        }
      }

      for (final launch in kLaunchPoints) {
        if (_knownUnsnappedLaunchIds.contains(launch.id)) {
          continue;
        }
        final graph = graphs[launch.riverSystem.name];
        if (graph == null) {
          continue;
        }

        final snap = graph.snapToVertex(
          launch.latitude,
          launch.longitude,
          maxSnapMeters: kReachabilitySnapMaxMeters,
        );
        expect(
          snap,
          isNotNull,
          reason:
              '${launch.id} (${launch.riverSystem.name}) is farther than '
              '${kReachabilitySnapMaxMeters.toInt()} m from bundled geometry',
        );
      }
    });
  });
}
