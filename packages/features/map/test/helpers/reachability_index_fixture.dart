/// Minimal reachability index JSON for map package tests.
const kTestReachabilityIndexJson = '''
{
  "schemaVersion": 1,
  "generatedAt": "2026-06-14T00:00:00.000Z",
  "distanceModel": "graph_plus_snap",
  "snapMaxMeters": 900.0,
  "thresholdsMi": [5, 10, 20],
  "crossSystemReachability": false,
  "entries": {
    "cathedral_park": {
      "5mi": ["swan_island_boat_ramp"],
      "10mi": ["sellwood_riverfront"],
      "20mi": ["jefferson_st_milwaukie"]
    },
    "unknown_launch": {
      "5mi": ["missing_launch_id"],
      "10mi": [],
      "20mi": []
    },
    "empty_launch": {
      "5mi": [],
      "10mi": [],
      "20mi": []
    }
  }
}
''';

Future<String> readTestReachabilityIndex() async => kTestReachabilityIndexJson;
