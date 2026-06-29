import 'package:eddyscout/routing/route_go_no_go_sections.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_localized_app.dart';

void main() {
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
}
