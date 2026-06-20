import 'package:eddyscout_hydro_routing/src/data/confluence_bridges.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseConfluenceBridgesJson', () {
    test('returns empty list for null input', () {
      expect(parseConfluenceBridgesJson(null), isEmpty);
    });

    test('parses valid bridge array', () {
      const json = '''
[
  {
    "id": "test_bridge",
    "a": {"lat": 45.1, "lon": -122.1},
    "b": {"lat": 45.2, "lon": -122.2}
  }
]
''';
      final bridges = parseConfluenceBridgesJson(json);
      expect(bridges, hasLength(1));
      expect(bridges.single.id, 'test_bridge');
      expect(bridges.single.aLat, 45.1);
      expect(bridges.single.bLon, -122.2);
    });

    test('skips malformed entries', () {
      const json = '''
[
  {"id": "bad"},
  {
    "id": "good",
    "a": {"lat": 1, "lon": 2},
    "b": {"lat": 3, "lon": 4}
  }
]
''';
      expect(parseConfluenceBridgesJson(json), hasLength(1));
    });
  });
}
