import 'package:eddyscout_hydro_routing/src/data/hydro_geojson_merge.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAndMergeHydroGeoJson', () {
    test('concatenates features from multiple documents', () {
      const doc1 = '''
{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"river_system":"a"},"geometry":{"type":"LineString","coordinates":[[0,0],[0,1]]}}]}
''';
      const doc2 = '''
{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"river_system":"b","reach_id":"reach_b"},"geometry":{"type":"LineString","coordinates":[[1,0],[1,1]]}}]}
''';
      final merged = parseAndMergeHydroGeoJson([doc1, doc2]);
      expect(merged, hasLength(2));
      expect(merged.first.riverSystemKey, 'a');
      expect(merged.last.reachId, 'reach_b');
    });

    test('throws when a document is not a FeatureCollection', () {
      expect(
        () => parseAndMergeHydroGeoJson(['{"type":"Point"}']),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('parseHydroGeoJson reach_id', () {
    test('reads reach_id from properties', () {
      const json = '''
{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"river_system":"columbia","reach_id":"columbia_gorge"},"geometry":{"type":"LineString","coordinates":[[-122.4,45.5],[-122.3,45.5]]}}]}
''';
      final features = parseHydroGeoJson(json);
      expect(features.single.reachId, 'columbia_gorge');
    });
  });
}
