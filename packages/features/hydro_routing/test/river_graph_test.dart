import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

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
      // Same mid-segment point — should not walk the full edge via Dijkstra.
      final r = g.route(0.05, 0.0, 0.05, 0.0, maxSnapMeters: 50000);
      expect(r, isA<RouteSuccess>());
      final ok = r as RouteSuccess;
      expect(ok.lengthMeters, lessThan(100));

      // Slightly off the line; edge snap should beat vertex snap distance.
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
  });

  group('parseHydroGeoJson', () {
    test('skips non-LineString', () {
      const json =
          '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[1,2]}}]}';
      expect(parseHydroGeoJson(json), isEmpty);
    });
  });
}
