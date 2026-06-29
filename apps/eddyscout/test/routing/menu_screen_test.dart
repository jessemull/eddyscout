import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/routing/menu_screen.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
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
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_localized_app.dart';
import 'test_router_overrides.dart';

class _MockGpxFileGateway extends Mock implements GpxFileGateway {}

const _sampleGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg>
    <trkpt lat="45.5880" lon="-122.7588"/>
    <trkpt lat="45.4670" lon="-122.6635"/>
  </trkseg></trk>
</gpx>''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;
  late _MockGpxFileGateway gateway;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
    gateway = _MockGpxFileGateway();
  });

  List<Override> menuOverrides({List<Override> extra = const []}) => [
    ...buildAppProviderOverrides(
      keyValueStore: store,
      mapboxTokenOverride: 'pk.test-token',
      mapInteractiveOverride: true,
      gpxFileGatewayOverride: gateway,
    ),
    firebaseBootstrapProvider.overrideWithValue(const FirebaseBootstrapState()),
    mapboxMapControllerProvider.overrideWith(MapboxMapController.new),
    ...appShellTestOverrides,
    analyticsClientProvider.overrideWithValue(RecordingAnalyticsClient()),
    ...extra,
  ];

  Future<void> pumpMenuWidget(
    WidgetTester tester, {
    List<Override> extra = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: menuOverrides(extra: extra),
        child: testLocalizedApp(child: const MenuScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpMenuRoute(
    WidgetTester tester, {
    List<Override> extra = const [],
  }) async {
    final router = GoRouter(
      routes: $appRoutes,
      initialLocation: RoutePaths.menu,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: menuOverrides(extra: extra),
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
  }

  testWidgets('MenuScreen navigates to settings', (tester) async {
    await pumpMenuRoute(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MenuScreen)),
    );

    await tester.tap(find.text(l10n.menuSettings));
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsScreenTitle), findsOneWidget);
    expect(find.text(l10n.settingsPaddleSpeedLabel), findsOneWidget);
  });

  testWidgets('MenuScreen about opens dialog', (tester) async {
    await pumpMenuWidget(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MenuScreen)),
    );
    await tester.tap(find.text(l10n.menuAbout));
    await tester.pumpAndSettle();

    expect(find.byType(AboutDialog), findsOneWidget);
    expect(find.text(l10n.appTitle), findsWidgets);
  });

  testWidgets('MenuScreen export shows success snackbar when route exists', (
    tester,
  ) async {
    when(
      () => gateway.writeAndShareGpx(
        filename: any(named: 'filename'),
        gpxXml: any(named: 'gpxXml'),
      ),
    ).thenAnswer((_) async => const Result.success(null));

    await pumpMenuWidget(
      tester,
      extra: [
        routePlanningProvider.overrideWith(
          () => _PlannedRoutePlanning(const [
            [-122.73, 45.56],
            [-122.66, 45.47],
          ]),
        ),
      ],
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MenuScreen)),
    );
    await tester.tap(find.text(l10n.menuExportGpx));
    await tester.pumpAndSettle();

    expect(find.text(l10n.mapGpxExportSuccess), findsOneWidget);
  });

  testWidgets('MenuScreen export shows failure snackbar when share fails', (
    tester,
  ) async {
    when(
      () => gateway.writeAndShareGpx(
        filename: any(named: 'filename'),
        gpxXml: any(named: 'gpxXml'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(
        StorageFailure(message: 'gpx_file_write_failed'),
      ),
    );

    await pumpMenuWidget(
      tester,
      extra: [
        routePlanningProvider.overrideWith(
          () => _PlannedRoutePlanning(const [
            [-122.73, 45.56],
            [-122.66, 45.47],
          ]),
        ),
      ],
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MenuScreen)),
    );
    await tester.tap(find.text(l10n.menuExportGpx));
    await tester.pumpAndSettle();

    expect(find.text(l10n.mapGpxFailureFileWrite), findsOneWidget);
  });

  testWidgets('MenuScreen import failure shows snackbar', (tester) async {
    when(() => gateway.pickAndReadGpx()).thenAnswer(
      (_) async => const Result.failure(
        StorageFailure(message: 'gpx_file_read_failed'),
      ),
    );

    await pumpMenuWidget(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MenuScreen)),
    );
    await tester.tap(find.text(l10n.menuImportGpx));
    await tester.pumpAndSettle();

    expect(find.text(l10n.mapGpxFailureFileRead), findsOneWidget);
  });

  testWidgets('MenuScreen import success navigates to map preview', (
    tester,
  ) async {
    when(() => gateway.pickAndReadGpx()).thenAnswer(
      (_) async => const Result.success(_sampleGpx),
    );

    await pumpMenuRoute(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MenuScreen)),
    );
    await tester.tap(find.text(l10n.menuImportGpx));
    await tester.pumpAndSettle();

    expect(find.text(l10n.mapGpxImportSuccess), findsOneWidget);
    expect(find.text(l10n.mapRoutePreviewStart), findsOneWidget);
  });

  testWidgets('MenuScreen shows moderator queue entry for moderators', (
    tester,
  ) async {
    FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
    addTearDown(FirebaseFlagsTestHooks.reset);
    await pumpMenuWidget(
      tester,
      extra: [
        moderatorAccessProvider.overrideWith((ref) async => true),
      ],
    );

    expect(
      find.byKey(const Key('menu_moderator_review_queue')),
      findsOneWidget,
    );
    expect(find.text('Review Reports'), findsOneWidget);
  });

  testWidgets('MenuScreen hides moderator queue entry for non-moderators', (
    tester,
  ) async {
    FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
    addTearDown(FirebaseFlagsTestHooks.reset);
    await pumpMenuWidget(
      tester,
      extra: [
        moderatorAccessProvider.overrideWith((ref) async => false),
      ],
    );

    expect(find.byKey(const Key('menu_moderator_review_queue')), findsNothing);
  });
}

class _PlannedRoutePlanning extends RoutePlanning {
  _PlannedRoutePlanning(this.polyline);

  final List<List<double>> polyline;

  @override
  RoutePlanningState build() => RoutePlanningState(
    phase: MapPlanningPhase.routeReady,
    stops: [
      RoutePlanningStop.catalog(kLaunchPoints.first),
      RoutePlanningStop.catalog(kLaunchPoints[1]),
    ],
    routeLengthKm: 12,
    activeGeometry: RouteGeometrySnapshot(
      polylineLonLat: polyline,
      lengthMeters: 12000,
      computedAt: DateTime.utc(2026),
    ),
    routeOrigin: RouteOrigin.planner,
  );
}
