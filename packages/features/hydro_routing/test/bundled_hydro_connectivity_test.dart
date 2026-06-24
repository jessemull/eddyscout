import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

void main() {
  group('bundled hydro connectivity', () {
    test('loads all assets and builds non-empty per-system graphs', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final features = parseAndMergeHydroGeoJson(docs);

      const expectedSystems = [
        'willamette',
        'columbia',
        'clackamas',
        'slough',
        'tualatin',
      ];

      for (final system in expectedSystems) {
        final graph = RiverLineGraph.fromFeatures(
          features,
          riverSystemName: system,
        );
        expect(
          graph.vertexCount,
          greaterThan(0),
          reason: 'expected graph vertices for $system',
        );
      }
    });
  });
}
