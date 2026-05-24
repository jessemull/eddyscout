import 'package:eddyscout/routing/river_geojson.dart';
import 'package:eddyscout/routing/river_graph.dart';
import 'package:eddyscout/routing/route_result.dart';
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

      // Line runs north along lon=0; use (lat, lon) order for route().
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
  });

  group('parseHydroGeoJson', () {
    test('skips non-LineString', () {
      const json =
          '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[1,2]}}]}';
      expect(parseHydroGeoJson(json), isEmpty);
    });
  });
}
