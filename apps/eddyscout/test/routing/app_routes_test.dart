import 'dart:async';

import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/main.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/routing/home_screen.dart';
import 'package:eddyscout/routing/menu_screen.dart';
import 'package:eddyscout/routing/settings_screen.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_router_overrides.dart';

SavedRoute _shellTestRoute() {
  final now = DateTime.utc(2026);
  return SavedRoute(
    id: 'sr_123',
    name: 'Shell Test Route',
    waypoints: const [
      RouteWaypoint.catalog(launchId: 'a', order: 0),
      RouteWaypoint.catalog(launchId: 'b', order: 1),
    ],
    metadata: const SavedRouteMetadata(),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;
  late RecordingAnalyticsClient analytics;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
    analytics = RecordingAnalyticsClient();
  });

  List<Override> appOverrides({List<Override> extra = const []}) => [
    ...buildAppProviderOverrides(
      keyValueStore: store,
      mapboxTokenOverride: 'pk.test-token',
      mapInteractiveOverride: true,
    ),
    firebaseBootstrapProvider.overrideWithValue(const FirebaseBootstrapState()),
    ...appShellTestOverrides,
    analyticsClientProvider.overrideWithValue(analytics),
    ...extra,
  ];

  Future<void> pumpAt(
    WidgetTester tester, {
    required String location,
    List<Override> extra = const [],
  }) async {
    final router = GoRouter(
      routes: $appRoutes,
      initialLocation: location,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: appOverrides(extra: extra),
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
      ),
    );
  }

  testWidgets('known launch route renders launch detail', (tester) async {
    await pumpAt(tester, location: '/launch/cathedral_park');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(LaunchDetailScreen), findsOneWidget);
  });

  testWidgets('unknown launch route renders not-found screen', (tester) async {
    await pumpAt(
      tester,
      location: '/launch/not-a-real-launch',
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(LaunchNotFoundScreen), findsOneWidget);
    expect(analytics.screenViews, [AnalyticsScreenNames.launchNotFound]);
  });

  testWidgets('non-not-found launch provider error shows unavailable body', (
    tester,
  ) async {
    await pumpAt(
      tester,
      location: '/launch/cathedral_park',
      extra: [
        launchPointByIdProvider('cathedral_park').overrideWith(
          (ref) => Future<LaunchPoint>.error(
            const NetworkFailure(message: 'offline'),
          ),
        ),
      ],
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(LaunchNotFoundScreen), findsNothing);
    expect(find.text('offline'), findsOneWidget);
  });

  testWidgets('delayed launch provider shows loading indicator', (
    tester,
  ) async {
    final completer = Completer<LaunchPoint>();
    addTearDown(() => completer.complete(kLaunchPoints.first));

    await pumpAt(
      tester,
      location: '/launch/cathedral_park',
      extra: [
        launchPointByIdProvider('cathedral_park').overrideWith(
          (ref) => completer.future,
        ),
      ],
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('map route navigates to launch detail on pin tap', (
    tester,
  ) async {
    await pumpAt(tester, location: '/');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    container
        .read(mapboxMapControllerProvider.notifier)
        .onLaunchCircleTap(
          CircleAnnotation(
            id: 'cathedral_park',
            geometry: Point(coordinates: Position(0, 0)),
            customData: <String, Object>{'launchId': 'cathedral_park'},
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('View conditions'), findsOneWidget);
    await tester.ensureVisible(find.text('View conditions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View conditions'));
    await tester.pumpAndSettle();

    expect(find.byType(LaunchDetailScreen), findsOneWidget);
  });

  testWidgets('back from launch detail restores map browse search', (
    tester,
  ) async {
    await pumpAt(tester, location: '/');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MapScreen)),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    container
        .read(mapboxMapControllerProvider.notifier)
        .onLaunchCircleTap(
          CircleAnnotation(
            id: 'cathedral_park',
            geometry: Point(coordinates: Position(0, 0)),
            customData: <String, Object>{'launchId': 'cathedral_park'},
          ),
        );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.mapViewConditionsButton));
    await tester.pumpAndSettle();
    expect(find.byType(LaunchDetailScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.mapSearchPlaceholder), findsOneWidget);
    expect(find.text(l10n.mapViewConditionsButton), findsNothing);
  });

  testWidgets('gate routes render routing package screens', (tester) async {
    await pumpAt(tester, location: '/missing-token');
    await tester.pumpAndSettle();
    expect(find.byType(MissingMapboxTokenScreen), findsOneWidget);

    await pumpAt(tester, location: '/web');
    await tester.pumpAndSettle();
    expect(find.byType(WebMapPlaceholderScreen), findsOneWidget);
  });

  testWidgets('home and menu shell routes render tab screens', (tester) async {
    await pumpAt(tester, location: RoutePaths.home);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    await pumpAt(tester, location: RoutePaths.menu);
    await tester.pumpAndSettle();
    expect(find.byType(MenuScreen), findsOneWidget);
  });

  testWidgets('settings route renders settings screen', (tester) async {
    await pumpAt(tester, location: '/settings');
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('EddyScoutApp builds MaterialApp.router shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: appOverrides(),
        child: const EddyScoutApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Search rivers, launches, places…'), findsOneWidget);
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
      final router = GoRouter(
        routes: $appRoutes,
        initialLocation: '/saved-routes/sr_123',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...appOverrides(
              extra: [
                savedRouteByIdProvider(
                  'sr_123',
                ).overrideWith((ref) async => _shellTestRoute()),
              ],
            ),
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
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Route details'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Shell Test Route'),
        findsOneWidget,
      );

      final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(nav.selectedIndex, 2);
    });

    testWidgets('switching to map tab notifies mapTabResumed', (tester) async {
      await pumpAt(tester, location: '/saved-routes');
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(NavigationBar)),
      );
      expect(container.read(mapTabResumedProvider), 0);

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      expect(container.read(mapTabResumedProvider), 1);
    });
  });
}
