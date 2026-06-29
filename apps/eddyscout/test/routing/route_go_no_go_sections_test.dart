import 'package:eddyscout/routing/route_go_no_go_sections.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MapRouteGoNoGoSection hides when fewer than two stops', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MapRouteGoNoGoSection(launchIdsInOrder: ['only-one']),
          ),
        ),
      ),
    );

    expect(find.byType(RouteGoNoGoSummarySection), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('MapRouteGoNoGoSection shows summary for two stops', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(
            RouteGoNoGoWaypointsKey.fromOrdered([
              'cathedral_park',
              'sellwood_riverfront',
            ]),
          ).overrideWith(
            (_) async => RouteGoNoGoResult(
              verdict: GoNoGoVerdict.go,
              computedAt: DateTime.utc(2026, 6, 15),
              waypointResults: const [],
              waypointFailures: const [],
              triggeringReasons: const [],
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MapRouteGoNoGoSection(
              launchIdsInOrder: ['cathedral_park', 'sellwood_riverfront'],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(RouteGoNoGoSummarySection), findsOneWidget);
  });

  testWidgets('SavedRouteGoNoGoSection hides for single-waypoint route', (
    tester,
  ) async {
    final route = SavedRoute(
      id: 'sr-1',
      name: 'Short',
      waypoints: const [RouteWaypoint(launchId: 'a', order: 0)],
      metadata: const SavedRouteMetadata(),
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedRouteByIdProvider(route.id).overrideWith((_) async => route),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SavedRouteGoNoGoSection(routeId: route.id),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(RouteGoNoGoSummarySection), findsNothing);
  });

  testWidgets('SavedRouteGoNoGoSection shows summary for multi-stop route', (
    tester,
  ) async {
    final route = SavedRoute(
      id: 'sr-2',
      name: 'Shuttle',
      waypoints: const [
        RouteWaypoint(launchId: 'cathedral_park', order: 1),
        RouteWaypoint(launchId: 'sellwood_riverfront', order: 0),
      ],
      metadata: const SavedRouteMetadata(distanceMeters: 5000),
      createdAt: DateTime.utc(2026, 6, 1),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedRouteByIdProvider(route.id).overrideWith((_) async => route),
          routeGoNoGoRollupProvider(
            RouteGoNoGoWaypointsKey.fromOrdered([
              'sellwood_riverfront',
              'cathedral_park',
            ]),
          ).overrideWith(
            (_) async => RouteGoNoGoResult(
              verdict: GoNoGoVerdict.marginal,
              computedAt: DateTime.utc(2026, 6, 15),
              waypointResults: const [],
              waypointFailures: const [],
              triggeringReasons: const [],
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SavedRouteGoNoGoSection(routeId: route.id),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(RouteGoNoGoSummarySection), findsOneWidget);
  });
}
