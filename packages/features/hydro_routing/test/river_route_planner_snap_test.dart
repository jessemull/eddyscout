import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

Future<RiverRoutePlanner> _willamettePlanner() async {
  final raw = await File(
    'test/fixtures/willamette_waterway.geojson',
  ).readAsString();
  return RiverRoutePlanner.fromGeoJson(raw);
}

void main() {
  group('RiverRoutePlanner snap APIs', () {
    test('snapToWaterway returns snapped point on bundled geometry', () async {
      final planner = await _willamettePlanner();
      const lat = 45.5152;
      const lon = -122.6784;

      final snap = planner.snapToWaterway(lat, lon);

      expect(snap, isNotNull);
      expect(snap!.distanceMeters, lessThanOrEqualTo(900));
      expect(snap.latitude, isNot(equals(lat)));
      expect(snap.longitude, isNot(equals(lon)));
    });

    test('snapToWaterway returns null off water', () async {
      final planner = await _willamettePlanner();

      final snap = planner.snapToWaterway(44.0, -123.0);

      expect(snap, isNull);
    });

    test('validateCoordinateSnap fails off water', () async {
      final planner = await _willamettePlanner();

      final failure = planner.validateCoordinateSnap(44.0, -123.0);

      expect(failure, isA<RouteFailure>());
      expect(failure?.code, RouteFailureCode.putInTooFar);
    });

    test('validateStop accepts catalog and snap stops on geometry', () async {
      final planner = await _willamettePlanner();
      const snap = WaterwaySnapPoint(
        latitude: 45.5152,
        longitude: -122.6784,
        distanceMeters: 10,
      );
      final stop = RoutePlanningStop.snap(
        id: 'snap_test',
        latitude: snap.latitude,
        longitude: snap.longitude,
        label: 'Custom',
      );

      expect(planner.validateStop(stop), isNull);
    });

    test(
      'planBetween routes coordinate pairs without differentSystem remap',
      () async {
        final planner = await _willamettePlanner();
        const lat1 = 45.5152;
        const lon1 = -122.6784;
        const lat2 = 45.5200;
        const lon2 = -122.6700;

        final result = planner.planBetween(lat1, lon1, lat2, lon2);

        expect(result, isA<RouteSuccess>());
      },
    );

    test('planStops chains consecutive stops', () async {
      final planner = await _willamettePlanner();
      const lat1 = 45.5152;
      const lon1 = -122.6784;
      const lat2 = 45.5200;
      const lon2 = -122.6700;
      const lat3 = 45.5250;
      const lon3 = -122.6600;
      final stops = [
        RoutePlanningStop.snap(
          id: 's1',
          latitude: lat1,
          longitude: lon1,
          label: 'A',
        ),
        RoutePlanningStop.snap(
          id: 's2',
          latitude: lat2,
          longitude: lon2,
          label: 'B',
        ),
        RoutePlanningStop.snap(
          id: 's3',
          latitude: lat3,
          longitude: lon3,
          label: 'C',
        ),
      ];

      final result = planner.planStops(stops);

      expect(result, isA<Success<List<RouteSuccess>, RouteFailure>>());
      final segments =
          (result as Success<List<RouteSuccess>, RouteFailure>).value;
      expect(segments, hasLength(2));
    });

    test('validateSegmentStops rejects cross-system catalog stops', () async {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {"type": "Feature", "properties": {"river_system": "willamette"}, "geometry": {"type": "LineString", "coordinates": [[-122.759, 45.588], [-122.758, 45.587]]}},
    {"type": "Feature", "properties": {"river_system": "slough"}, "geometry": {"type": "LineString", "coordinates": [[-122.763, 45.646], [-122.762, 45.645]]}}
  ]
}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final putIn = findLaunchPointById('cathedral_park')!;
      final takeOut = findLaunchPointById('kelley_point')!;
      final failure = planner.validateSegmentStops(
        RoutePlanningStop.catalog(putIn),
        RoutePlanningStop.catalog(takeOut),
      );
      expect(failure, isA<RouteFailure>());
      expect(
        failure!.code,
        anyOf(
          RouteFailureCode.differentSystem,
          RouteFailureCode.disconnectedReach,
          RouteFailureCode.noConnectedPath,
        ),
      );
    });

    test('nearestSnapResult matches indexed snap on test graph', () {
      final graph = RiverLineGraph.forTesting(
        lat: [40.0, 40.02],
        lon: [-100.0, -100.0],
        adj: [
          [
            (to: 1, w: 2220.0, riverSystem: null, oneWay: false),
          ],
          [
            (to: 0, w: 2220.0, riverSystem: null, oneWay: false),
          ],
        ],
      );

      final indexed = graph.nearestSnapResult(
        40.01,
        -100.0,
        maxSnapMeters: 50000,
      );
      final brute = graph.nearestSnapBruteForceForTesting(
        40.01,
        -100.0,
        50000,
      );

      expect(indexed, isNotNull);
      expect(brute, isNotNull);
      expect(indexed!.lat, closeTo(brute!.lat, 1e-9));
      expect(indexed.lon, closeTo(brute.lon, 1e-9));
    });
  });
}
