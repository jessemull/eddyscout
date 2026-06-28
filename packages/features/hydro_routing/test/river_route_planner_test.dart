import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

LaunchPoint _launch({
  required String id,
  required RiverSystem river,
  required double lat,
  required double lon,
}) {
  return LaunchPoint(
    id: id,
    name: id,
    latitude: lat,
    longitude: lon,
    shortNote: 'Test',
    riverSystem: river,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

Future<RiverRoutePlanner> _plannerFromFixtures() async {
  const fixtureNames = [
    'willamette_waterway.geojson',
    'columbia_lower_waterway.geojson',
    'columbia_gorge_waterway.geojson',
    'clackamas_waterway.geojson',
    'slough_waterway.geojson',
    'tualatin_waterway.geojson',
    'sandy_waterway.geojson',
  ];
  final docs = <String>[];
  for (final name in fixtureNames) {
    docs.add(await File('test/fixtures/$name').readAsString());
  }
  return RiverRoutePlanner.fromGeoJsonDocuments(docs);
}

Future<RiverRoutePlanner> _plannerFromBundledAssets() async {
  final docs = await readBundledHydroGeoJsonDocuments();
  final bridges = await readBundledConfluenceBridgesJson();
  return RiverRoutePlanner.fromGeoJsonDocuments(
    docs,
    confluenceBridgesJson: bridges,
  );
}

void main() {
  group('RiverRoutePlanner.plan', () {
    test('empty geometry returns noRiverGeometryLoaded not noBundledLine', () {
      const json = '''
{"type":"FeatureCollection","features":[]}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final putIn = _launch(
        id: 'a',
        river: RiverSystem.willamette,
        lat: 45.5,
        lon: -122.6,
      );
      final takeOut = _launch(
        id: 'b',
        river: RiverSystem.willamette,
        lat: 45.51,
        lon: -122.61,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteFailure>());
      final failure = result as RouteFailure;
      expect(failure.code, RouteFailureCode.noRiverGeometryLoaded);
      expect(failure.code, isNot(RouteFailureCode.noBundledLine));
    });

    test('sameLaunch returns sameLaunch failure', () async {
      final planner = await _plannerFromFixtures();
      final launch = _launch(
        id: 'a',
        river: RiverSystem.willamette,
        lat: 45.5124,
        lon: -122.6754,
      );
      final result = planner.plan(launch, launch);
      expect(result, isA<RouteFailure>());
      expect((result as RouteFailure).code, RouteFailureCode.sameLaunch);
    });

    test(
      'differentSystem when cross-system launches are not connected',
      () {
        const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {"type": "LineString", "coordinates": [[-122.67, 45.51], [-122.66, 45.51]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "columbia"},
      "geometry": {"type": "LineString", "coordinates": [[-122.42, 45.58], [-122.41, 45.58]]}
    }
  ]
}
''';
        final planner = RiverRoutePlanner.fromGeoJson(json);
        final putIn = _launch(
          id: 'w',
          river: RiverSystem.willamette,
          lat: 45.51,
          lon: -122.67,
        );
        final takeOut = _launch(
          id: 'c',
          river: RiverSystem.columbia,
          lat: 45.58,
          lon: -122.42,
        );
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteFailure>());
        expect((result as RouteFailure).code, RouteFailureCode.differentSystem);
      },
    );

    test('crossSystem routes when confluence bridge connects systems', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette", "reach_id": "w_reach"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "columbia", "reach_id": "c_reach"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0.02], [0, 0.03]]}
    }
  ]
}
''';
      const bridgesJson = '''
[
  {
    "id": "test_confluence",
    "a": {"lat": 0.01, "lon": 0},
    "b": {"lat": 0.02, "lon": 0}
  }
]
''';
      final planner = RiverRoutePlanner.fromGeoJson(
        json,
        confluenceBridgesJson: bridgesJson,
      );
      final putIn = _launch(
        id: 'w',
        river: RiverSystem.willamette,
        lat: 0.0,
        lon: 0.0,
      );
      final takeOut = _launch(
        id: 'c',
        river: RiverSystem.columbia,
        lat: 0.03,
        lon: 0.0,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
      final ok = result as RouteSuccess;
      expect(ok.lengthMeters, greaterThan(0));
      expect(ok.polylineLonLat.length, greaterThan(2));
    });

    test('putInTooFar when launch has no nearby geometry', () {
      const json = '''
{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"river_system":"willamette"},"geometry":{"type":"LineString","coordinates":[[-122.67,45.51],[-122.66,45.51]]}}]}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final launch = _launch(
        id: 's',
        river: RiverSystem.slough,
        lat: 45.6463,
        lon: -122.7580,
      );
      final result = planner.plan(
        launch,
        _launch(
          id: 's2',
          river: RiverSystem.slough,
          lat: 45.6464,
          lon: -122.7581,
        ),
      );
      expect(result, isA<RouteFailure>());
      expect((result as RouteFailure).code, RouteFailureCode.putInTooFar);
    });

    test(
      'cross-system putInTooFar is not remapped to differentSystem',
      () {
        const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {"type": "LineString", "coordinates": [[-122.67, 45.51], [-122.66, 45.51]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "columbia"},
      "geometry": {"type": "LineString", "coordinates": [[-122.42, 45.58], [-122.41, 45.58]]}
    }
  ]
}
''';
        final planner = RiverRoutePlanner.fromGeoJson(json);
        final putIn = _launch(
          id: 'far',
          river: RiverSystem.willamette,
          lat: 45.6463,
          lon: -122.7580,
        );
        final takeOut = _launch(
          id: 'c',
          river: RiverSystem.columbia,
          lat: 45.58,
          lon: -122.42,
        );
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteFailure>());
        expect((result as RouteFailure).code, RouteFailureCode.putInTooFar);
      },
    );

    test(
      'cross-system takeOutTooFar is not remapped to differentSystem',
      () {
        const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {"type": "LineString", "coordinates": [[-122.67, 45.51], [-122.66, 45.51]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "columbia"},
      "geometry": {"type": "LineString", "coordinates": [[-122.42, 45.58], [-122.41, 45.58]]}
    }
  ]
}
''';
        final planner = RiverRoutePlanner.fromGeoJson(json);
        final putIn = _launch(
          id: 'w',
          river: RiverSystem.willamette,
          lat: 45.51,
          lon: -122.67,
        );
        final takeOut = _launch(
          id: 'far',
          river: RiverSystem.columbia,
          lat: 45.6463,
          lon: -122.7580,
        );
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteFailure>());
        expect((result as RouteFailure).code, RouteFailureCode.takeOutTooFar);
      },
    );

    test('routes Willamette launches along bundled geometry', () async {
      final planner = await _plannerFromFixtures();
      final putIn = _launch(
        id: 'tom_mccall',
        river: RiverSystem.willamette,
        lat: 45.5124,
        lon: -122.6754,
      );
      final takeOut = _launch(
        id: 'sellwood',
        river: RiverSystem.willamette,
        lat: 45.4709,
        lon: -122.6617,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
      final ok = result as RouteSuccess;
      expect(ok.lengthMeters, greaterThan(100));
      expect(ok.polylineLonLat.length, greaterThan(2));
    });

    test('same-system regression on bundled app assets', () async {
      final planner = await _plannerFromBundledAssets();
      final putIn = _launch(
        id: 'cathedral_park',
        river: RiverSystem.willamette,
        lat: 45.5621,
        lon: -122.7328,
      );
      final takeOut = _launch(
        id: 'sellwood_riverfront',
        river: RiverSystem.willamette,
        lat: 45.4709,
        lon: -122.6617,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
    });

    test(
      'cross-system routes on bundled assets via lower Columbia geometry',
      () async {
        final planner = await _plannerFromBundledAssets();
        final putIn = _launch(
          id: 'cathedral_park',
          river: RiverSystem.willamette,
          lat: 45.5621,
          lon: -122.7328,
        );
        final takeOut = _launch(
          id: 'glenn_otto_troutdale',
          river: RiverSystem.columbia,
          lat: 45.5365,
          lon: -122.3858,
        );
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteSuccess>());
        final ok = result as RouteSuccess;
        expect(ok.lengthMeters, greaterThan(1000));
        expect(ok.polylineLonLat.length, greaterThan(2));
      },
    );

    test(
      'Cathedral Park to Glenn Otto stays clear of Vancouver Wintler anchor',
      () async {
        final planner = await _plannerFromBundledAssets();
        final putIn = _launch(
          id: 'cathedral_park',
          river: RiverSystem.willamette,
          lat: 45.5621,
          lon: -122.7328,
        );
        final takeOut = _launch(
          id: 'glenn_otto_troutdale',
          river: RiverSystem.columbia,
          lat: 45.5365,
          lon: -122.3858,
        );
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteSuccess>());
        final ok = result as RouteSuccess;

        const wintlerLat = 45.6275;
        const wintlerLon = -122.6558;
        const minClearanceMeters = 150.0;

        for (final point in ok.polylineLonLat) {
          final distance = haversineMeters(
            wintlerLat,
            wintlerLon,
            point[1],
            point[0],
          );
          expect(
            distance,
            greaterThan(minClearanceMeters),
            reason:
                'Route vertex ${point[0]}, ${point[1]} is only '
                '${distance.toStringAsFixed(1)} m from Vancouver Wintler',
          );
        }
      },
    );

    test(
      'Port of Camas marina routes via Camas Slough spur geometry',
      () async {
        final planner = await _plannerFromBundledAssets();
        final putIn = _launch(
          id: 'port_of_camas',
          river: RiverSystem.columbia,
          lat: 45.5856,
          lon: -122.4244,
        );
        final takeOut = _launch(
          id: 'glenn_otto_troutdale',
          river: RiverSystem.columbia,
          lat: 45.5365,
          lon: -122.3858,
        );
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteSuccess>());
        final ok = result as RouteSuccess;
        expect(ok.lengthMeters, greaterThan(100));
        expect(ok.polylineLonLat.length, greaterThan(2));
      },
    );

    test(
      'cross-system routes on bundled assets without confluence bridges',
      () async {
        final docs = await readBundledHydroGeoJsonDocuments();
        final planner = RiverRoutePlanner.fromGeoJsonDocuments(docs);
        final putIn = _launch(
          id: 'cathedral_park',
          river: RiverSystem.willamette,
          lat: 45.5621,
          lon: -122.7328,
        );
        final takeOut = _launch(
          id: 'glenn_otto_troutdale',
          river: RiverSystem.columbia,
          lat: 45.5365,
          lon: -122.3858,
        );
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteSuccess>());
      },
    );

    test('routes Columbia gorge launches along bundled geometry', () async {
      final planner = await _plannerFromFixtures();
      final putIn = _launch(
        id: 'port_of_camas',
        river: RiverSystem.columbia,
        lat: 45.5856,
        lon: -122.4244,
      );
      final takeOut = _launch(
        id: 'glenn_otto_troutdale',
        river: RiverSystem.columbia,
        lat: 45.5365,
        lon: -122.3858,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
      final ok = result as RouteSuccess;
      expect(ok.lengthMeters, greaterThan(100));
    });

    test('disconnectedReach when launches snap to separate reaches', () async {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette", "reach_id": "reach_a"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "willamette", "reach_id": "reach_b"},
      "geometry": {"type": "LineString", "coordinates": [[0, 1], [0, 1.01]]}
    }
  ]
}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final putIn = _launch(
        id: 'a',
        river: RiverSystem.willamette,
        lat: 0.0,
        lon: 0.0,
      );
      final takeOut = _launch(
        id: 'b',
        river: RiverSystem.willamette,
        lat: 1.0,
        lon: 0.0,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteFailure>());
      final failure = result as RouteFailure;
      expect(failure.code, RouteFailureCode.disconnectedReach);
      expect(failure.putInReachId, 'reach_a');
      expect(failure.takeOutReachId, 'reach_b');
    });
  });

  group('planMultiSegmentRoute', () {
    test('returns disconnectedReach on first failing segment', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette", "reach_id": "reach_a"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "willamette", "reach_id": "reach_b"},
      "geometry": {"type": "LineString", "coordinates": [[0, 1], [0, 1.01]]}
    }
  ]
}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final putIn = _launch(
        id: 'a',
        river: RiverSystem.willamette,
        lat: 0.0,
        lon: 0.0,
      );
      final takeOut = _launch(
        id: 'b',
        river: RiverSystem.willamette,
        lat: 1.0,
        lon: 0.0,
      );
      final result = planMultiSegmentRoute(planner, [putIn, takeOut]);
      expect(result, isA<Failure<List<RouteSuccess>, RouteFailure>>());
      final failure =
          (result as Failure<List<RouteSuccess>, RouteFailure>).error;
      expect(failure.code, RouteFailureCode.disconnectedReach);
      expect(failure.putInReachId, 'reach_a');
      expect(failure.takeOutReachId, 'reach_b');
    });
  });

  group('RiverRoutePlanner.planLaunches', () {
    test('returns result and planned route together on success', () async {
      final planner = await _plannerFromFixtures();
      final putIn = _launch(
        id: 'port_of_camas',
        river: RiverSystem.columbia,
        lat: 45.5856,
        lon: -122.4244,
      );
      final takeOut = _launch(
        id: 'glenn_otto_troutdale',
        river: RiverSystem.columbia,
        lat: 45.5365,
        lon: -122.3858,
      );
      final (:result, :planned) = planner.planLaunches(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
      expect(planned, isNotNull);
      expect(planned!.putIn?.id, 'port_of_camas');
      expect(planned.takeOut?.id, 'glenn_otto_troutdale');
      expect(planned.points.length, greaterThan(1));
    });
  });

  group('RiverRoutePlanner.planRoute', () {
    test('returns PlannedRoute on success and null on failure', () async {
      final planner = await _plannerFromFixtures();
      final putIn = _launch(
        id: 'port_of_camas',
        river: RiverSystem.columbia,
        lat: 45.5856,
        lon: -122.4244,
      );
      final takeOut = _launch(
        id: 'glenn_otto_troutdale',
        river: RiverSystem.columbia,
        lat: 45.5365,
        lon: -122.3858,
      );
      final planned = planner.planRoute(putIn, takeOut);
      expect(planned, isNotNull);
      expect(planned!.putIn?.id, 'port_of_camas');
      expect(planned.takeOut?.id, 'glenn_otto_troutdale');
      expect(planned.lengthMeters, greaterThan(100));
      expect(planned.toPolylineLonLat().length, greaterThan(1));

      expect(
        planner.planRoute(putIn, putIn),
        isNull,
      );
    });
  });

  group('two-coordinate launch model', () {
    test(
      'cathedral to glenn otto polyline is graph-only with distinct water entry',
      () async {
        final planner = await _plannerFromBundledAssets();
        final putIn = findLaunchPointById('cathedral_park')!;
        final takeOut = findLaunchPointById('glenn_otto_troutdale')!;
        expect(putIn.hasDistinctWaterEntry, isTrue);
        expect(takeOut.hasDistinctWaterEntry, isTrue);

        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteSuccess>());
        final ok = result as RouteSuccess;
        expect(ok.polylineLonLat.length, greaterThan(2));

        final first = ok.polylineLonLat.first;
        final last = ok.polylineLonLat.last;

        expect(
          haversineMeters(
            putIn.accessLatitude,
            putIn.accessLongitude,
            first[1],
            first[0],
          ),
          greaterThan(50),
          reason: 'polyline must not start at inland access pin',
        );

        expect(
          haversineMeters(
            putIn.routingLatitude,
            putIn.routingLongitude,
            first[1],
            first[0],
          ),
          lessThan(kCatalogWaterEntrySnapMaxMeters),
        );

        expect(
          haversineMeters(
            takeOut.routingLatitude,
            takeOut.routingLongitude,
            last[1],
            last[0],
          ),
          lessThan(kCatalogWaterEntrySnapMaxMeters),
        );
      },
    );

    test('Columbia pool launches route on bundled assets', () async {
      final planner = await _plannerFromBundledAssets();
      final putIn = findLaunchPointById('frenchmans_bar')!;
      final takeOut = findLaunchPointById('st_helens_public_marina')!;
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
    });

    test('Willamette launches route on bundled assets', () async {
      final planner = await _plannerFromBundledAssets();
      final putIn = findLaunchPointById('cedaroak_boat_ramp')!;
      final takeOut = findLaunchPointById('sellwood_riverfront')!;
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
    });

    test(
      'cross-system cathedral park routes to Kelley Point slough launch',
      () async {
        final planner = await _plannerFromBundledAssets();
        final putIn = findLaunchPointById('cathedral_park')!;
        final takeOut = findLaunchPointById('kelley_point')!;
        final result = planner.plan(putIn, takeOut);
        expect(result, isA<RouteSuccess>());
        expect(
          (result as RouteSuccess).lengthMeters,
          greaterThan(5000),
        );
      },
    );

    test('north Columbia launches snap on bundled geometry', () async {
      final planner = await _plannerFromBundledAssets();
      for (final id in [
        'frenchmans_bar',
        'st_helens_public_marina',
      ]) {
        final launch = findLaunchPointById(id)!;
        expect(planner.validateLaunchSnap(launch), isNull, reason: id);
      }
    });

    test(
      'validateLaunchSnap rejects launches far from bundled geometry',
      () async {
        final planner = await _plannerFromBundledAssets();
        final farLaunch = _launch(
          id: 'far',
          river: RiverSystem.willamette,
          lat: 44.0,
          lon: -123.0,
        );
        expect(
          planner.validateLaunchSnap(farLaunch)?.code,
          RouteFailureCode.putInTooFar,
        );
      },
    );

    test('validateSegment rejects disconnected launches', () async {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette"},
      "geometry": {"type": "LineString", "coordinates": [[-122.759, 45.588], [-122.758, 45.587]]}
    },
    {
      "type": "Feature",
      "properties": {"river_system": "slough"},
      "geometry": {"type": "LineString", "coordinates": [[-122.763, 45.646], [-122.762, 45.645]]}
    }
  ]
}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final putIn = findLaunchPointById('cathedral_park')!;
      final takeOut = findLaunchPointById('kelley_point')!;
      expect(planner.validateSegment(putIn, takeOut), isA<RouteFailure>());
    });
  });
}
