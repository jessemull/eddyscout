import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_suggested_trips_index_generator.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_suggested_trips_index.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';
import 'package:flutter_test/flutter_test.dart';

LaunchPoint _launch({
  required String id,
  required double lat,
  required double lon,
}) {
  return LaunchPoint(
    id: id,
    name: id,
    latitude: lat,
    longitude: lon,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

void main() {
  group('LaunchSuggestedTripsIndexGenerator', () {
    test('caps one-way suggestions and builds round trips at 2x', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.02], [0, 0.04], [0, 0.08], [0, 0.12]]
      }
    }
  ]
}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final launches = List.generate(
        12,
        (index) => _launch(
          id: 'launch_$index',
          lat: index * 0.01,
          lon: 0,
        ),
      );

      final index = LaunchSuggestedTripsIndexGenerator.generate(
        planner: planner,
        catalog: launches,
        generatedAt: DateTime.utc(2026, 1, 1),
        maxOneWaySuggestions: 8,
        maxRoundTripSuggestions: 5,
      );

      final entry = index.entryFor('launch_0')!;
      expect(entry.oneWay.length, lessThanOrEqualTo(8));
      expect(entry.roundTrips.length, lessThanOrEqualTo(5));
      expect(entry.roundTrips.length, lessThanOrEqualTo(entry.oneWay.length));

      for (final roundTrip in entry.roundTrips) {
        final matchingOneWay = entry.oneWay.firstWhere(
          (trip) => trip.destination == roundTrip.destination,
        );
        expect(
          roundTrip.distanceKm,
          closeTo(matchingOneWay.distanceKm * 2, 0.001),
        );
        expect(
          roundTrip.estimatedMinutes,
          matchingOneWay.estimatedMinutes * 2,
        );
        expect(roundTrip.waypoints.first, 'launch_0');
        expect(roundTrip.waypoints.last, 'launch_0');
      }
    });

    test(
      'buildOneWayTrip throws StateError when trip time cannot be estimated',
      () {
        final source = _launch(id: 'launch_a', lat: 0, lon: 0);
        final target = _launch(id: 'launch_b', lat: 0.01, lon: 0);
        const route = RouteSuccess(
          polylineLonLat: [
            [0, 0],
            [0, 0.01],
          ],
          lengthMeters: 0,
        );

        expect(
          () => LaunchSuggestedTripsIndexGenerator.buildOneWayTrip(
            source: source,
            target: target,
            route: route,
            catalog: [source, target],
            paddleSpeedKmh: kSuggestedTripsDefaultPaddleSpeedKmh,
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('excludes destinations beyond 20 mi graph distance', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[0, 0], [0, 0.25]]
      }
    }
  ]
}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final near = _launch(id: 'near', lat: 0, lon: 0);
      final far = _launch(id: 'far', lat: 0.25, lon: 0);
      final index = LaunchSuggestedTripsIndexGenerator.generate(
        planner: planner,
        catalog: [near, far],
        generatedAt: DateTime.utc(2026, 1, 1),
      );

      final dist =
          (planner.plan(near, far) as RouteSuccess).lengthMeters / 1000;
      if (dist > kSuggestedTripsMaxDistanceMeters / 1000) {
        expect(index.entryFor('near')!.oneWay, isEmpty);
      }
    });
  });

  group('estimateSuggestedTripMinutes', () {
    test('returns minutes from distance and speed', () {
      expect(
        estimateSuggestedTripMinutes(distanceKm: 8, speedKmh: 4),
        120,
      );
      expect(estimateSuggestedTripMinutes(distanceKm: 0), isNull);
    });
  });
}
