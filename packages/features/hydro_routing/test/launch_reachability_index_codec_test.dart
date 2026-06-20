import 'package:eddyscout_hydro_routing/src/data/launch_reachability_index_codec.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLaunchReachabilityIndex', () {
    test('parses schema metadata and exclusive bands', () {
      const json = '''
{
  "schemaVersion": 1,
  "generatedAt": "2026-06-14T00:00:00.000Z",
  "distanceModel": "graph_plus_snap",
  "snapMaxMeters": 900,
  "thresholdsMi": [5, 10, 20],
  "crossSystemReachability": false,
  "entries": {
    "cathedral_park": {
      "5mi": ["swan_island_boat_ramp"],
      "10mi": ["sellwood_riverfront"],
      "20mi": []
    }
  }
}
''';

      final index = parseLaunchReachabilityIndex(json);
      expect(index.schemaVersion, 1);
      expect(index.crossSystemReachability, isFalse);
      expect(index.snapMaxMeters, 900);

      final entry = index.entryFor('cathedral_park');
      expect(entry, isNotNull);
      expect(entry!.within5Mi, ['swan_island_boat_ramp']);
      expect(entry.within10Mi, ['sellwood_riverfront']);
      expect(entry.within20Mi, isEmpty);

      expect(
        index.nearbyLaunchIds(
          'cathedral_park',
          ReachabilityBand.within10Mi,
        ),
        ['sellwood_riverfront'],
      );
      expect(
        index.nearbyLaunchIds('unknown', ReachabilityBand.within5Mi),
        <String>[],
      );
    });

    test('round-trips through encode', () {
      final index = LaunchReachabilityIndex(
        schemaVersion: 1,
        generatedAt: DateTime.utc(2026, 6, 14),
        distanceModel: 'graph_plus_snap',
        snapMaxMeters: 900,
        thresholdsMi: kReachabilityThresholdsMi,
        crossSystemReachability: false,
        entries: {
          'a': const LaunchReachabilityEntry(
            within5Mi: ['b'],
            within10Mi: ['c'],
          ),
        },
      );

      final parsed = parseLaunchReachabilityIndex(
        encodeLaunchReachabilityIndex(index),
      );
      expect(parsed.entries['a']?.within5Mi, ['b']);
      expect(parsed.entries['a']?.within10Mi, ['c']);
    });
  });
}
