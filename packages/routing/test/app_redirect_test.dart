import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> _testRoutes() => [
  GoRoute(
    path: RoutePaths.map,
    builder: (_, state) => const SizedBox(),
  ),
  GoRoute(
    path: RoutePaths.launchDetail,
    builder: (_, state) => const SizedBox(),
  ),
  GoRoute(
    path: RoutePaths.missingToken,
    builder: (_, state) => const SizedBox(),
  ),
  GoRoute(
    path: RoutePaths.web,
    builder: (_, state) => const SizedBox(),
  ),
];

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Router.withConfig(config: router),
    ),
  );
}

void main() {
  group('initialAppLocation', () {
    test('without Mapbox token resolves to missing-token', () {
      expect(initialAppLocation(), RoutePaths.missingToken);
    });

    test('with Mapbox token resolves to map', () {
      expect(
        initialAppLocationFor(isWeb: false, hasMapboxToken: true),
        RoutePaths.map,
      );
    });

    test('on web resolves to web placeholder', () {
      expect(
        initialAppLocationFor(isWeb: true, hasMapboxToken: true),
        RoutePaths.web,
      );
    });
  });

  group('resolveAppRedirect', () {
    test('redirects non-web routes to web on web platform', () {
      expect(
        resolveAppRedirect(
          location: RoutePaths.map,
          isWeb: true,
          hasMapboxToken: true,
          isKnownLaunchId: (_) => true,
        ),
        RoutePaths.web,
      );
    });

    test('redirects unknown launch id to map when token present', () {
      expect(
        resolveAppRedirect(
          location: RoutePaths.launchDetail,
          isWeb: false,
          hasMapboxToken: true,
          isKnownLaunchId: (_) => false,
          launchId: 'unknown_launch',
        ),
        RoutePaths.map,
      );
    });

    test('returns null for valid launch id when token present', () {
      expect(
        resolveAppRedirect(
          location: RoutePaths.launchDetail,
          isWeb: false,
          hasMapboxToken: true,
          isKnownLaunchId: (_) => true,
          launchId: 'cathedral_park',
        ),
        isNull,
      );
    });
  });

  group('appRedirect without Mapbox token', () {
    testWidgets('redirects map to missing-token', (tester) async {
      final router = createRouter(
        routes: _testRoutes(),
        initialLocation: RoutePaths.missingToken,
        redirect: appRedirect,
      );
      await _pumpRouter(tester, router);

      router.go(RoutePaths.map);
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        RoutePaths.missingToken,
      );
    });

    testWidgets('allows missing-token route', (tester) async {
      final router = createRouter(
        routes: _testRoutes(),
        initialLocation: RoutePaths.missingToken,
        redirect: appRedirect,
      );
      await _pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        RoutePaths.missingToken,
      );
    });

    testWidgets('stays on missing-token when navigating to same path', (
      tester,
    ) async {
      final router = createRouter(
        routes: _testRoutes(),
        redirect: appRedirect,
      );
      await _pumpRouter(tester, router);

      expect(
        router.routeInformationProvider.value.uri.path,
        RoutePaths.missingToken,
      );

      router.go(RoutePaths.missingToken);
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        RoutePaths.missingToken,
      );
    });
  });
}
