import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

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
  final willamette = await File(
    'test/fixtures/willamette_waterway.geojson',
  ).readAsString();
  final columbia = await File(
    'test/fixtures/columbia_gorge_waterway.geojson',
  ).readAsString();
  return RiverRoutePlanner.fromGeoJsonDocuments([willamette, columbia]);
}

void main() {
  group('RiverRoutePlanner.plan', () {
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

    test('differentSystem returns differentSystem failure', () async {
      final planner = await _plannerFromFixtures();
      final putIn = _launch(
        id: 'w',
        river: RiverSystem.willamette,
        lat: 45.5124,
        lon: -122.6754,
      );
      final takeOut = _launch(
        id: 'c',
        river: RiverSystem.columbia,
        lat: 45.5856,
        lon: -122.4244,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteFailure>());
      expect((result as RouteFailure).code, RouteFailureCode.differentSystem);
    });

    test('noBundledLine when river system has no geometry', () {
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
      final failure = result as RouteFailure;
      expect(failure.code, RouteFailureCode.noBundledLine);
      expect(failure.riverSystemName, 'slough');
    });

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

    test('routes Columbia gorge launches along bundled geometry', () async {
      final planner = await _plannerFromFixtures();
      final putIn = _launch(
        id: 'port_of_camas',
        river: RiverSystem.columbia,
        lat: 45.5856,
        lon: -122.4244,
      );
      final takeOut = _launch(
        id: 'washougal',
        river: RiverSystem.columbia,
        lat: 45.5791,
        lon: -122.3870,
      );
      final result = planner.plan(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
      final ok = result as RouteSuccess;
      expect(ok.reachId, 'columbia_gorge');
      expect(ok.lengthMeters, greaterThan(100));
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
        id: 'washougal',
        river: RiverSystem.columbia,
        lat: 45.5791,
        lon: -122.3870,
      );
      final (:result, :planned) = planner.planLaunches(putIn, takeOut);
      expect(result, isA<RouteSuccess>());
      expect(planned, isNotNull);
      expect(planned!.putInLaunchId, 'port_of_camas');
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
        id: 'washougal',
        river: RiverSystem.columbia,
        lat: 45.5791,
        lon: -122.3870,
      );
      final planned = planner.planRoute(putIn, takeOut);
      expect(planned, isNotNull);
      expect(planned!.putInLaunchId, 'port_of_camas');
      expect(planned.takeOutLaunchId, 'washougal');
      expect(planned.riverSystem, RiverSystem.columbia);
      expect(planned.reachId, 'columbia_gorge');

      expect(
        planner.planRoute(putIn, putIn),
        isNull,
      );
    });
  });
}
