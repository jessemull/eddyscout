import 'dart:convert';
import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bundled launch suggested trips index asset', () {
    const assetPath = 'assets/data/launch_suggested_trips_index.json';

    test('$assetPath exists and parses with expected schema', () {
      final file = File(assetPath);
      expect(file.existsSync(), isTrue, reason: 'missing asset $assetPath');

      final index = parseLaunchSuggestedTripsIndex(file.readAsStringSync());

      expect(index.schemaVersion, 1);
      expect(index.distanceModel, 'graph_plus_snap');
      expect(index.snapMaxMeters, kReachabilitySnapMaxMeters);
      expect(index.maxDistanceMi, kSuggestedTripsMaxDistanceMi);
      expect(index.paddleSpeedKmh, kSuggestedTripsDefaultPaddleSpeedKmh);
      expect(index.maxOneWaySuggestions, kSuggestedTripsMaxOneWay);
      expect(index.maxRoundTripSuggestions, kSuggestedTripsMaxRoundTrip);
      expect(index.crossSystemReachability, isFalse);
      expect(index.entries, isNotEmpty);

      for (final launch in kLaunchPoints) {
        expect(
          index.entries.containsKey(launch.id),
          isTrue,
          reason: 'missing entry for ${launch.id}',
        );
        final entry = index.entries[launch.id]!;
        expect(
          entry.oneWay.length,
          lessThanOrEqualTo(kSuggestedTripsMaxOneWay),
        );
        expect(
          entry.roundTrips.length,
          lessThanOrEqualTo(kSuggestedTripsMaxRoundTrip),
        );
        for (final trip in [...entry.oneWay, ...entry.roundTrips]) {
          expect(
            kLaunchPoints.any((l) => l.id == trip.destination),
            isTrue,
            reason: 'unknown destination ${trip.destination}',
          );
          expect(trip.waypoints.first, launch.id);
          for (final waypointId in trip.waypoints) {
            expect(
              kLaunchPoints.any((l) => l.id == waypointId),
              isTrue,
              reason: 'unknown waypoint $waypointId',
            );
          }
        }
      }
    });

    test('$assetPath is valid JSON with required top-level keys', () {
      final root =
          jsonDecode(File(assetPath).readAsStringSync())
              as Map<String, dynamic>;

      expect(root['schemaVersion'], isA<int>());
      expect(root['generatedAt'], isA<String>());
      expect(root['distanceModel'], isA<String>());
      expect(root['snapMaxMeters'], isA<num>());
      expect(root['maxDistanceMi'], isA<num>());
      expect(root['paddleSpeedKmh'], isA<num>());
      expect(root['maxOneWaySuggestions'], isA<num>());
      expect(root['maxRoundTripSuggestions'], isA<num>());
      expect(root['crossSystemReachability'], isA<bool>());

      final entries = root['entries'] as Map<String, dynamic>;
      expect(entries, isNotEmpty);

      for (final entry in entries.values) {
        final value = entry as Map<String, dynamic>;
        expect(value.keys, containsAll(['oneWay', 'roundTrips']));
        for (final list in value.values) {
          expect(list, isA<List<dynamic>>());
        }
      }
    });
  });
}
