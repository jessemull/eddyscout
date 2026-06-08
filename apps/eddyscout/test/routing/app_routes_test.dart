import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/routing/saved_routes_database_override.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

SavedRoute _shellTestRoute() {
  final now = DateTime.utc(2026);
  return SavedRoute(
    id: 'sr_123',
    name: 'Shell Test Route',
    waypoints: const [
      RouteWaypoint(launchId: 'a', order: 0),
      RouteWaypoint(launchId: 'b', order: 1),
    ],
    metadata: const SavedRouteMetadata(),
    createdAt: now,
    updatedAt: now,
  );
}

Widget _shellTestApp(GoRouter router) {
  return ProviderScope(
    overrides: [
      savedRoutesDatabaseTestOverride(),
      launchPointLookupProvider.overrideWithValue((_) => null),
      savedRouteByIdProvider(
        'sr_123',
      ).overrideWith((ref) async => _shellTestRoute()),
      analyticsClientProvider.overrideWithValue(const NoOpAnalyticsClient()),
    ],
    child: MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

GoRouter _shellTestRouter({required String initialLocation}) => createRouter(
  routes: $appRoutes,
  initialLocation: initialLocation,
  redirect: (context, state) => resolveAppRedirect(
    location: state.matchedLocation,
    isWeb: false,
    hasMapboxToken: true,
    isKnownLaunchId: (id) => findLaunchPointById(id) != null,
    launchId: state.pathParameters['launchId'],
  ),
);

void main() {
  group('LaunchDetailRoute', () {
    test('location encodes launch id', () {
      const route = LaunchDetailRoute(launchId: 'cathedral_park');

      expect(route.location, '/launch/cathedral_park');
    });
  });

  group('MapRoute', () {
    test('location is root path', () {
      expect(const MapRoute().location, RoutePaths.map);
    });
  });

  group('SavedRoutesListRoute', () {
    test('location is saved routes path', () {
      expect(
        const SavedRoutesListRoute().location,
        RoutePaths.savedRoutes,
      );
    });
  });

  group('SavedRouteDetailRoute', () {
    test('location encodes route id', () {
      const route = SavedRouteDetailRoute(routeId: 'sr_123');
      expect(route.location, '/saved-routes/sr_123');
    });
  });

  group('AppShell navigation', () {
    testWidgets('deep link to saved route detail selects saved tab', (
      tester,
    ) async {
      final router = _shellTestRouter(initialLocation: '/saved-routes/sr_123');
      await tester.pumpWidget(_shellTestApp(router));
      await tester.pumpAndSettle();

      expect(find.text('Route details'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Shell Test Route'),
        findsOneWidget,
      );

      final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(nav.selectedIndex, 1);
    });
  });
}
