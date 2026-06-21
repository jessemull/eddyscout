import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_suggested_trips_index_generator.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_suggested_trips_index.dart';
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
  group('LaunchSuggestedTripsIndexGenerator integration', () {
    test('cathedral_park includes sellwood_riverfront within top 8', () async {
      final planner = await _plannerFromFixtures();
      final index = LaunchSuggestedTripsIndexGenerator.generate(
        planner: planner,
        catalog: kLaunchPoints,
        generatedAt: DateTime.utc(2026, 6, 20),
      );

      final cathedral = index.entryFor('cathedral_park')!;
      expect(
        cathedral.oneWay.length,
        lessThanOrEqualTo(kSuggestedTripsMaxOneWay),
      );
      expect(
        cathedral.oneWay.map((trip) => trip.destination),
        contains('sellwood_riverfront'),
      );
    });

    test(
      'excludes cross-system pairs when unified graph unavailable',
      () async {
        final planner = await _plannerFromFixtures();
        final index = LaunchSuggestedTripsIndexGenerator.generate(
          planner: planner,
          catalog: kLaunchPoints,
        );

        expect(index.crossSystemReachability, isFalse);
        final kelley = index.entryFor('kelley_point')!;
        expect(kelley.oneWay, isEmpty);
        expect(kelley.roundTrips, isEmpty);

        final cathedral = index.entryFor('cathedral_park')!;
        expect(
          cathedral.oneWay.map((trip) => trip.destination),
          isNot(contains('kelley_point')),
        );
      },
    );

    test('round trips are capped and double one-way metrics', () async {
      final planner = await _plannerFromFixtures();
      final index = LaunchSuggestedTripsIndexGenerator.generate(
        planner: planner,
        catalog: kLaunchPoints,
      );

      final cathedral = index.entryFor('cathedral_park')!;
      expect(
        cathedral.roundTrips.length,
        lessThanOrEqualTo(kSuggestedTripsMaxRoundTrip),
      );
      for (final roundTrip in cathedral.roundTrips) {
        final oneWay = cathedral.oneWay.firstWhere(
          (trip) => trip.destination == roundTrip.destination,
        );
        expect(roundTrip.distanceKm, closeTo(oneWay.distanceKm * 2, 0.001));
        expect(roundTrip.estimatedMinutes, oneWay.estimatedMinutes * 2);
      }
    });
  });
}
