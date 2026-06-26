import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_reachability_index_generator.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('LaunchReachabilityIndexGenerator integration', () {
    test('Willamette pair in 5mi band on lower river pool', () async {
      final planner = await _plannerFromFixtures();
      final index = LaunchReachabilityIndexGenerator.generate(
        planner: planner,
        catalog: kLaunchPoints,
        generatedAt: DateTime.utc(2026, 6, 14),
      );

      final sellwood = index.entryFor('sellwood_riverfront')!;
      expect(sellwood.within5Mi, contains('willamette_park_sw'));
    });

    test(
      'excludes cross-system pairs when unified graph unavailable',
      () async {
        final planner = await _plannerFromFixtures();
        final index = LaunchReachabilityIndexGenerator.generate(
          planner: planner,
          catalog: kLaunchPoints,
        );

        expect(index.crossSystemReachability, isFalse);
        final kelley = index.entryFor('kelley_point')!;
        expect(kelley.within5Mi, isEmpty);
        expect(kelley.within10Mi, isEmpty);
        expect(kelley.within20Mi, isEmpty);

        final cathedral = index.entryFor('cathedral_park')!;
        expect(cathedral.within5Mi, isNot(contains('kelley_point')));
        expect(cathedral.within10Mi, isNot(contains('kelley_point')));
        expect(cathedral.within20Mi, isNot(contains('kelley_point')));
      },
    );
  });
}
