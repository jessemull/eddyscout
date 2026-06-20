import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_reachability_index_generator.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
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
  group('LaunchReachabilityIndexGenerator', () {
    test('assigns exclusive distance bands on a synthetic chain', () {
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
      final launchA = _launch(id: 'launch_a', lat: 0, lon: 0);
      final launchB = _launch(id: 'launch_b', lat: 0.02, lon: 0);
      final launchC = _launch(id: 'launch_c', lat: 0.08, lon: 0);
      final launchD = _launch(id: 'launch_d', lat: 0.12, lon: 0);
      final catalog = [launchA, launchB, launchC, launchD];

      final index = LaunchReachabilityIndexGenerator.generate(
        planner: planner,
        catalog: catalog,
        generatedAt: DateTime.utc(2026, 1, 1),
      );

      final entryA = index.entryFor('launch_a')!;
      expect(entryA.within5Mi, contains('launch_b'));
      expect(entryA.within5Mi, isNot(contains('launch_c')));

      final distAC =
          (planner.plan(launchA, launchC) as RouteSuccess).lengthMeters;
      final bandAC = reachabilityBandForDistance(distAC);
      if (bandAC == ReachabilityBand.within10Mi) {
        expect(entryA.within10Mi, contains('launch_c'));
        expect(entryA.within5Mi, isNot(contains('launch_c')));
      } else {
        expect(bandAC, ReachabilityBand.within5Mi);
        expect(entryA.within5Mi, contains('launch_c'));
      }

      final distAD =
          (planner.plan(launchA, launchD) as RouteSuccess).lengthMeters;
      final bandAD = reachabilityBandForDistance(distAD);
      expect(bandAD, isNotNull);
      expect(
        entryA.launchIdsFor(bandAD!),
        contains('launch_d'),
      );
      expect(entryA.within5Mi, isNot(contains('launch_d')));
    });
  });
}
