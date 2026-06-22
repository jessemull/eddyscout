import 'package:eddyscout_hydro_routing/src/data/launch_suggested_trips_index_codec.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_suggested_trips_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLaunchSuggestedTripsIndex', () {
    test('parses schema metadata and trip lists', () {
      const json = '''
{
  "schemaVersion": 1,
  "generatedAt": "2026-06-20T00:00:00.000Z",
  "distanceModel": "graph_plus_snap",
  "snapMaxMeters": 900,
  "maxDistanceMi": 20,
  "paddleSpeedKmh": 4.0,
  "maxOneWaySuggestions": 8,
  "maxRoundTripSuggestions": 5,
  "crossSystemReachability": false,
  "entries": {
    "cathedral_park": {
      "oneWay": [
        {
          "destination": "sellwood_riverfront",
          "distanceKm": 8.2,
          "estimatedMinutes": 123,
          "waypoints": ["cathedral_park", "sellwood_riverfront"]
        }
      ],
      "roundTrips": [
        {
          "destination": "sellwood_riverfront",
          "distanceKm": 16.4,
          "estimatedMinutes": 246,
          "waypoints": ["cathedral_park", "sellwood_riverfront", "cathedral_park"]
        }
      ]
    }
  }
}
''';

      final index = parseLaunchSuggestedTripsIndex(json);
      expect(index.schemaVersion, 1);
      expect(index.crossSystemReachability, isFalse);
      expect(index.snapMaxMeters, 900);
      expect(index.paddleSpeedKmh, 4.0);

      final entry = index.entryFor('cathedral_park');
      expect(entry, isNotNull);
      expect(entry!.oneWay, hasLength(1));
      expect(entry.oneWay.first.destination, 'sellwood_riverfront');
      expect(entry.roundTrips, hasLength(1));
      expect(entry.roundTrips.first.distanceKm, 16.4);

      expect(
        index.oneWayTripsFor('cathedral_park').first.destination,
        'sellwood_riverfront',
      );
      expect(index.oneWayTripsFor('unknown'), isEmpty);
    });

    test('round-trips through encode', () {
      final index = LaunchSuggestedTripsIndex(
        schemaVersion: 1,
        generatedAt: DateTime.utc(2026, 6, 20),
        distanceModel: 'graph_plus_snap',
        snapMaxMeters: kReachabilitySnapMaxMeters,
        maxDistanceMi: kSuggestedTripsMaxDistanceMi,
        paddleSpeedKmh: kSuggestedTripsDefaultPaddleSpeedKmh,
        maxOneWaySuggestions: kSuggestedTripsMaxOneWay,
        maxRoundTripSuggestions: kSuggestedTripsMaxRoundTrip,
        crossSystemReachability: false,
        entries: {
          'a': LaunchSuggestedTripsEntry(
            oneWay: const [
              SuggestedTrip(
                destination: 'b',
                distanceKm: 5,
                estimatedMinutes: 75,
                waypoints: ['a', 'b'],
              ),
            ],
            roundTrips: const [
              SuggestedTrip(
                destination: 'b',
                distanceKm: 10,
                estimatedMinutes: 150,
                waypoints: ['a', 'b', 'a'],
              ),
            ],
          ),
        },
      );

      final parsed = parseLaunchSuggestedTripsIndex(
        encodeLaunchSuggestedTripsIndex(index),
      );
      expect(parsed.entries['a']?.oneWay.first.destination, 'b');
      expect(parsed.entries['a']?.roundTrips.first.distanceKm, 10);
    });
  });
}
