import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/confluence_bridges.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/dijkstra_reference.dart';
import 'helpers/synthetic_grid_features.dart';
import 'helpers/synthetic_grid_graph.dart';

void main() {
  group('RiverLineGraph', () {
    test('shortest path along a simple chain', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "testriver"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.01], [0, 0.02]]
      }
    }
  ]
}
''';
      final feats = parseHydroGeoJson(json);
      final g = RiverLineGraph.fromFeatures(
        feats,
        riverSystemName: 'testriver',
      );
      expect(g.vertexCount, greaterThanOrEqualTo(3));

      final r = g.route(0.0, 0.0, 0.02, 0.0, maxSnapMeters: 50000);
      expect(r, isA<RouteSuccess>());
      final ok = r as RouteSuccess;
      expect(ok.polylineLonLat.length, greaterThanOrEqualTo(2));
      expect(ok.lengthMeters, greaterThan(0));
    });

    test('fails when snap too far', () {
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
      final feats = parseHydroGeoJson(json);
      final g = RiverLineGraph.fromFeatures(feats, riverSystemName: 'tiny');
      final r = g.route(40.0, -100.0, 40.0, -100.0, maxSnapMeters: 50);
      expect(r, isA<RouteFailure>());
    });

    test('edge snap finds point mid-segment closer than vertices', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "edge"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.1]]
      }
    }
  ]
}
''';
      final feats = parseHydroGeoJson(json);
      final g = RiverLineGraph.fromFeatures(feats, riverSystemName: 'edge');
      final r = g.route(0.05, 0.0, 0.05, 0.0, maxSnapMeters: 50000);
      expect(r, isA<RouteSuccess>());
      final ok = r as RouteSuccess;
      expect(ok.lengthMeters, lessThan(100));

      final offLine = g.route(0.05, 0.001, 0.08, 0.001, maxSnapMeters: 2000);
      expect(offLine, isA<RouteSuccess>());
    });

    test('disconnectedReach when endpoints are on separate segments', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "split", "reach_id": "reach_a"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "split", "reach_id": "reach_b"},
      "geometry": {"type": "LineString", "coordinates": [[0, 1], [0, 1.01]]}
    }
  ]
}
''';
      final feats = parseHydroGeoJson(json);
      final g = RiverLineGraph.fromFeatures(feats, riverSystemName: 'split');
      final r = g.route(0.0, 0.0, 1.0, 0.0, maxSnapMeters: 50000);
      expect(r, isA<RouteFailure>());
      final failure = r as RouteFailure;
      expect(failure.code, RouteFailureCode.disconnectedReach);
      expect(failure.putInReachId, 'reach_a');
      expect(failure.takeOutReachId, 'reach_b');
    });

    test('A* matches reference Dijkstra on chain graph', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "chain"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.01], [0, 0.02], [0, 0.03]]
      }
    }
  ]
}
''';
      final g = RiverLineGraph.fromFeatures(
        parseHydroGeoJson(json),
        riverSystemName: 'chain',
      );
      final astar = g.astarForTesting(0, g.vertexCount - 1);
      final dijkstra = dijkstraReference(g, 0, g.vertexCount - 1);
      expect(astar, dijkstra);
    });

    test('haversine heuristic is admissible for all vertices', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "grid"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.01], [0.01, 0.01]]
      }
    }
  ]
}
''';
      final g = RiverLineGraph.fromFeatures(
        parseHydroGeoJson(json),
        riverSystemName: 'grid',
      );
      final dst = g.vertexCount - 1;
      for (var v = 0; v < g.vertexCount; v++) {
        final h = haversineMeters(
          g.latitudeAt(v),
          g.longitudeAt(v),
          g.latitudeAt(dst),
          g.longitudeAt(dst),
        );
        final pathDist = g.shortestPathDistanceForTesting(v, dst);
        if (pathDist.isFinite) {
          expect(h, lessThanOrEqualTo(pathDist));
        }
      }
    });

    test('A* path matches Dijkstra on zigzag geometry', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "zig"},
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [0, 0],
          [0.01, 0],
          [0.01, 0.01],
          [0.02, 0.01]
        ]
      }
    }
  ]
}
''';
      final g = RiverLineGraph.fromFeatures(
        parseHydroGeoJson(json),
        riverSystemName: 'zig',
      );
      final dst = g.vertexCount - 1;
      expect(g.astarForTesting(0, dst), dijkstraReference(g, 0, dst));
    });

    test('one-way edges block reverse traversal', () {
      final g = RiverLineGraph.forTesting(
        lat: [0, 0.01, 0.02],
        lon: [0, 0, 0],
        adj: [
          [(to: 1, w: 100, riverSystem: 'oneway', oneWay: true)],
          [(to: 2, w: 100, riverSystem: 'oneway', oneWay: true)],
          [],
        ],
      );
      expect(g.astarForTesting(0, 2), [0, 1, 2]);
      expect(g.astarForTesting(2, 0), isNull);
    });

    test('stores river_system on edges from features', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[-122.5, 45.5], [-122.5, 45.51]]
      }
    }
  ]
}
''';
      final g = RiverLineGraph.fromFeatures(
        parseHydroGeoJson(json),
        riverSystemName: 'willamette',
      );
      expect(g.adjacencyForTesting.first.first.riverSystem, 'willamette');
      expect(g.adjacencyForTesting.first.first.oneWay, isFalse);
    });

    test('merge threshold changes vertex count', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "merge"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.00001], [0, 0.02]]
      }
    }
  ]
}
''';
      final feats = parseHydroGeoJson(json);
      final tight = RiverLineGraph.fromFeatures(
        feats,
        riverSystemName: 'merge',
        mergeVertexMeters: 1,
      );
      final loose = RiverLineGraph.fromFeatures(
        feats,
        riverSystemName: 'merge',
        mergeVertexMeters: 500,
      );
      expect(loose.vertexCount, lessThan(tight.vertexCount));
    });

    test('parses one_way from GeoJSON', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "dir", "one_way": true},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.01]]
      }
    }
  ]
}
''';
      final feats = parseHydroGeoJson(json);
      expect(feats.single.oneWay, isTrue);
      final g = RiverLineGraph.fromFeatures(
        feats,
        riverSystemName: 'dir',
      );
      expect(g.adjacencyForTesting[0].single.oneWay, isTrue);
      expect(g.adjacencyForTesting[1], isEmpty);
    });

    test('synthetic grid is connected for pathfinding', () {
      for (final target in [100, 5000]) {
        final graph = buildSyntheticGridGraph(target);
        final last = graph.vertexCount - 1;
        expect(dijkstraReference(graph, 0, last), isNotNull);
        expect(graph.astarForTesting(0, last), isNotNull);
      }
    });

    test('fromFeatures grid build matches expected vertex count', () {
      for (final target in [100, 5000]) {
        final features = buildSyntheticGridFeatures(target);
        final graph = RiverLineGraph.fromFeatures(
          features,
          riverSystemName: 'bench',
        );
        expect(graph.vertexCount, syntheticGridVertexCount(target));
      }
    });

    group('reachability graph helpers', () {
      late RiverLineGraph chainGraph;

      setUp(() {
        const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "chain"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.01], [0, 0.02], [0, 0.03]]
      }
    }
  ]
}
''';
        chainGraph = RiverLineGraph.fromFeatures(
          parseHydroGeoJson(json),
          riverSystemName: 'chain',
        );
      });

      test('snapToVertex returns nearest vertex within threshold', () {
        final snap = chainGraph.snapToVertex(0.01, 0.0);
        expect(snap, isNotNull);
        expect(snap!.vertexIndex, isNotNull);
        expect(snap.snapMeters, lessThan(2000));
      });

      test('snapToVertex returns null when too far from geometry', () {
        expect(
          chainGraph.snapToVertex(40.0, -100.0, maxSnapMeters: 50),
          isNull,
        );
      });

      test('graphDistanceMeters matches A* path length', () {
        final last = chainGraph.vertexCount - 1;
        expect(
          chainGraph.graphDistanceMeters(0, last),
          chainGraph.shortestPathDistanceForTesting(0, last),
        );
      });

      test(
        'graphDistanceMeters returns null across disconnected components',
        () {
          const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "split"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "split"},
      "geometry": {"type": "LineString", "coordinates": [[0, 1], [0, 1.01]]}
    }
  ]
}
''';
          final split = RiverLineGraph.fromFeatures(
            parseHydroGeoJson(json),
            riverSystemName: 'split',
          );
          expect(split.graphDistanceMeters(0, 2), isNull);
        },
      );

      test('distancesWithin respects graph cutoff', () {
        final firstEdge = chainGraph.shortestPathDistanceForTesting(0, 1);
        final within = chainGraph.distancesWithin(0, firstEdge + 1);
        expect(within.keys, containsAll([0, 1]));
        expect(within[1], lessThanOrEqualTo(firstEdge + 1));
        expect(within.containsKey(chainGraph.vertexCount - 1), isFalse);
      });

      test('routeDistanceMeters matches route success length', () {
        final distance = chainGraph.routeDistanceMeters(0, 0, 0.03, 0);
        final result = chainGraph.route(0, 0, 0.03, 0);
        expect(distance, (result as RouteSuccess).lengthMeters);
      });
    });
  });

  group('parseHydroGeoJson', () {
    test('skips non-LineString', () {
      const json =
          '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[1,2]}}]}';
      expect(parseHydroGeoJson(json), isEmpty);
    });
  });

  group('RiverLineGraph unified build', () {
    test('fromAllFeatures merges overlapping cross-system vertices', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "slough"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0.01], [0, 0.02]]}
    }
  ]
}
''';
      final feats = parseHydroGeoJson(json);
      final unified = RiverLineGraph.fromAllFeatures(feats);
      final willametteOnly = RiverLineGraph.fromFeatures(
        feats,
        riverSystemName: 'willamette',
      );
      expect(unified.vertexCount, lessThan(willametteOnly.vertexCount + 2));
      final r = unified.route(0.0, 0.0, 0.02, 0.0, maxSnapMeters: 50000);
      expect(r, isA<RouteSuccess>());
    });

    test('addConfluenceBridges connects otherwise disconnected systems', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "alpha"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "beta"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0.03], [0, 0.04]]}
    }
  ]
}
''';
      final feats = parseHydroGeoJson(json);
      final withoutBridge = RiverLineGraph.fromAllFeatures(feats);
      expect(
        withoutBridge.route(0.0, 0.0, 0.04, 0.0, maxSnapMeters: 50000),
        isA<RouteFailure>(),
      );

      final withBridge = withoutBridge.addConfluenceBridges([
        const ConfluenceBridge(
          id: 'alpha_beta',
          aLat: 0.01,
          aLon: 0,
          bLat: 0.03,
          bLon: 0,
        ),
      ]);
      expect(
        withBridge.route(0.0, 0.0, 0.04, 0.0, maxSnapMeters: 50000),
        isA<RouteSuccess>(),
      );
    });

    test(
      'addConfluenceBridges skips bridge when endpoints are too far to snap',
      () {
        const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "alpha"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "beta"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0.03], [0, 0.04]]}
    }
  ]
}
''';
        final feats = parseHydroGeoJson(json);
        final withoutBridge = RiverLineGraph.fromAllFeatures(feats);
        final withBridge = withoutBridge.addConfluenceBridges([
          const ConfluenceBridge(
            id: 'placeholder_too_far',
            aLat: 1.0,
            aLon: 0,
            bLat: 2.0,
            bLon: 0,
          ),
        ]);

        expect(withBridge.vertexCount, withoutBridge.vertexCount);
        expect(
          withBridge.route(0.0, 0.0, 0.04, 0.0, maxSnapMeters: 50000),
          isA<RouteFailure>(),
        );
      },
    );
  });
}
