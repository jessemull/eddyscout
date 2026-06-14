import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/routing/app_shell.dart';
import 'package:eddyscout/routing/home_screen.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_router_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    final router = GoRouter(
      routes: $appRoutes,
      initialLocation: RoutePaths.home,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...buildAppProviderOverrides(
            keyValueStore: store,
            mapboxTokenOverride: 'pk.test-token',
            mapInteractiveOverride: true,
          ),
          firebaseBootstrapProvider.overrideWithValue(
            const FirebaseBootstrapState(),
          ),
          ...appShellTestOverrides,
          analyticsClientProvider.overrideWithValue(RecordingAnalyticsClient()),
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
  }

  testWidgets('HomeScreen renders placeholder and opens map tab', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.byType(HomeScreen), findsOneWidget);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(HomeScreen)),
    );
    expect(find.text(l10n.homePlaceholderBody), findsOneWidget);

    await tester.tap(find.text(l10n.homeExploreMapButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.mapSearchPlaceholder), findsOneWidget);
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.selectedIndex, AppShellBranches.map);
  });
}
