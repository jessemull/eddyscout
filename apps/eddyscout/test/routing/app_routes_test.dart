import 'dart:async';

import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/main.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
  });

  List<Override> appOverrides({List<Override> extra = const []}) => [
    ...buildAppProviderOverrides(
      keyValueStore: store,
      mapboxTokenOverride: 'pk.test-token',
      mapInteractiveOverride: true,
    ),
    firebaseBootstrapProvider.overrideWithValue(const FirebaseBootstrapState()),
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
    await pumpAt(tester, location: '/launch/not-a-real-launch');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(LaunchNotFoundScreen), findsOneWidget);
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

    expect(find.byType(LaunchDetailScreen), findsOneWidget);
  });

  testWidgets('gate routes render routing package screens', (tester) async {
    await pumpAt(tester, location: '/missing-token');
    await tester.pumpAndSettle();
    expect(find.byType(MissingMapboxTokenScreen), findsOneWidget);

    await pumpAt(tester, location: '/web');
    await tester.pumpAndSettle();
    expect(find.byType(WebMapPlaceholderScreen), findsOneWidget);
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
    expect(find.text('EddyScout'), findsOneWidget);
  });
}
