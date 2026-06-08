import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_screen.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';
import '../../helpers/test_saved_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpDetail(
    WidgetTester tester, {
    required String routeId,
    required List<Object?> overrides,
    void Function(SavedRoute route)? onLoadOnMap,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClientProvider.overrideWithValue(
            const NoOpAnalyticsClient(),
          ),
          launchPointLookupProvider.overrideWithValue((_) => null),
          ...overrides.cast(),
        ],
        child: testLocalizedApp(
          child: SavedRouteDetailScreen(
            routeId: routeId,
            onLoadOnMap: onLoadOnMap ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('shows not found when route is missing', (tester) async {
    await pumpDetail(
      tester,
      routeId: 'missing',
      overrides: [
        savedRouteByIdProvider('missing').overrideWith((ref) async => null),
      ],
    );

    expect(find.text('Route not found.'), findsOneWidget);
  });

  testWidgets('shows route name and load on map action', (tester) async {
    final route = testSavedRoute(name: 'Willamette Shuttle');

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: [
        savedRouteByIdProvider(route.id).overrideWith((ref) async => route),
      ],
    );

    expect(
      find.widgetWithText(TextField, 'Willamette Shuttle'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Load on map'),
      48,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Load on map'), findsOneWidget);
  });

  testWidgets('invokes onLoadOnMap when load button pressed', (tester) async {
    final route = testSavedRoute();
    SavedRoute? loadedRoute;

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: [
        savedRouteByIdProvider(route.id).overrideWith((ref) async => route),
      ],
      onLoadOnMap: (loaded) => loadedRoute = loaded,
    );

    await tester.scrollUntilVisible(
      find.text('Load on map'),
      48,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Load on map'));
    await tester.pump();

    expect(loadedRoute, isNotNull);
    expect(loadedRoute!.id, route.id);
  });
}
