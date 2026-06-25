import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/synthetic_grid_graph.dart';

void main() {
  group('GraphSnapIndex parity', () {
    test('matches brute force on chain graph', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "chain"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.01], [0, 0.02], [0.01, 0.02]]
      }
    }
  ]
}
''';
      final graph = RiverLineGraph.fromFeatures(
        parseHydroGeoJson(json),
        riverSystemName: 'chain',
      );
      _expectSnapParity(
        graph,
        queries: const [
          (0.005, 0.0),
          (0.01, 0.005),
          (0.015, 0.02),
        ],
      );
    });

    test('matches brute force on synthetic grid', () {
      final graph = buildSyntheticGridGraph(500);
      final queries = <(double, double)>[
        for (var i = 0; i < 50; i++)
          (
            graph.latitudeAt(i * 7),
            graph.longitudeAt(i * 7) + 0.0001,
          ),
      ];
      _expectSnapParity(graph, queries: queries, maxSnapMeters: 900);
    });

    test('respects maxSnapMeters cutoff', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "tiny"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[-122.0, 45.0], [-122.001, 45.0]]
      }
    }
  ]
}
''';
      final graph = RiverLineGraph.fromFeatures(
        parseHydroGeoJson(json),
        riverSystemName: 'tiny',
      );
      expect(
        graph.nearestSnapIndexedForTesting(40, -100, 50),
        isNull,
      );
      expect(
        graph.nearestSnapBruteForceForTesting(40, -100, 50),
        isNull,
      );
    });
  });
}

void _expectSnapParity(
  RiverLineGraph graph, {
  required List<(double, double)> queries,
  double maxSnapMeters = 50000,
}) {
  for (final (la, lo) in queries) {
    final indexed = graph.nearestSnapIndexedForTesting(la, lo, maxSnapMeters);
    final brute = graph.nearestSnapBruteForceForTesting(la, lo, maxSnapMeters);
    expect(indexed?.distanceMeters, brute?.distanceMeters);
    expect(indexed?.vertexIndex, brute?.vertexIndex);
    expect(indexed?.edgeU, brute?.edgeU);
    expect(indexed?.edgeV, brute?.edgeV);
    expect(indexed?.reachId, brute?.reachId);
  }
}
