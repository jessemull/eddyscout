import 'package:eddyscout/routing/route_go_no_go_sections.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_localized_app.dart';

void main() {
  group('routeGoNoGoStopMetadata helpers', () {
    test('builds metadata from mixed catalog and snap waypoints', () {
      const waypoints = [
        RouteWaypoint.catalog(launchId: 'cathedral_park', order: 1),
        RouteWaypoint.snap(
          latitude: 45.55,
          longitude: -122.67,
          order: 0,
          label: 'Early snap',
        ),
      ];

      final metadata = routeGoNoGoStopMetadataFromWaypoints(waypoints);

      expect(metadata.catalogLaunchIds, ['cathedral_park']);
      expect(metadata.catalogStopOrderIndices, [1]);
      expect(metadata.snapStops.single.label, 'Early snap');
      expect(routeGoNoGoTotalStopCount(metadata), 2);
    });

    test('builds metadata from planning stops with default snap label', () {
      const stops = [
        RoutePlanningStop.snap(
          id: 'snap_a',
          latitude: 45.5512,
          longitude: -122.6789,
          label: '45.5512, -122.6789',
        ),
        RoutePlanningStop.catalog(
          LaunchPoint(
            id: 'cathedral_park',
            name: 'Cathedral Park Boat Ramp',
            latitude: 45.5621,
            longitude: -122.7328,
            shortNote: 'note',
            riverSystem: RiverSystem.willamette,
            windExposure: WindExposure.moderate,
            tideRelevance: TideRelevance.none,
          ),
        ),
      ];

      final metadata = routeGoNoGoStopMetadataFromPlanningStops(stops);

      expect(metadata.catalogLaunchIds, ['cathedral_park']);
      expect(metadata.catalogStopOrderIndices, [1]);
      expect(metadata.snapStops.single.orderIndex, 0);
    });
  });

  testWidgets('SavedRouteGoNoGoSection shows snap-only unknown conditions', (
    tester,
  ) async {
    final route = SavedRoute(
      id: 'sr_snap_only',
      name: 'Custom only',
      waypoints: const [
        RouteWaypoint.snap(
          latitude: 45.5512,
          longitude: -122.6789,
          order: 0,
          label: 'Put-in bend',
        ),
        RouteWaypoint.snap(
          latitude: 45.5612,
          longitude: -122.6689,
          order: 1,
          label: 'Take-out eddy',
        ),
      ],
      metadata: const SavedRouteMetadata(),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedRouteByIdProvider('sr_snap_only').overrideWith(
            (ref) async => route,
          ),
        ],
        child: testLocalizedApp(
          child: const Scaffold(
            body: SavedRouteGoNoGoSection(routeId: 'sr_snap_only'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unknown conditions'), findsOneWidget);

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text('Put-in bend'), findsOneWidget);
    expect(find.text('Take-out eddy'), findsOneWidget);
    expect(find.text('No conditions data available'), findsNWidgets(2));
  });

  testWidgets('MapRouteGoNoGoSection shows snap-only unknown conditions', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: const Scaffold(
          body: MapRouteGoNoGoSection(
            catalogLaunchIds: [],
            catalogStopOrderIndices: [],
            snapStops: [
              RouteGoNoGoSnapStop(orderIndex: 0, label: 'Put-in bend'),
              RouteGoNoGoSnapStop(orderIndex: 1, label: 'Take-out eddy'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unknown conditions'), findsOneWidget);
  });
}
