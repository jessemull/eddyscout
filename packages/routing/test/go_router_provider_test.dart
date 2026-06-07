import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

ProviderContainer _routerContainer() {
  final container = ProviderContainer(
    overrides: [
      routesProvider.overrideWithValue(_testRoutes()),
      isKnownLaunchIdProvider.overrideWithValue((_) => true),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('goRouterProvider initial location without Mapbox token', () {
    final container = _routerContainer();

    final router = container.read(goRouterProvider);
    expect(
      router.routeInformationProvider.value.uri.path,
      RoutePaths.missingToken,
    );
  });

  test('goRouterProvider throws without isKnownLaunchIdProvider override', () {
    final container = ProviderContainer(
      overrides: [
        routesProvider.overrideWithValue(_testRoutes()),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(goRouterProvider),
      throwsA(
        predicate(
          (error) =>
              error.toString().contains('Override isKnownLaunchIdProvider'),
        ),
      ),
    );
  });

  test('goRouterProvider throws without routesProvider override', () {
    final container = ProviderContainer(
      overrides: [
        isKnownLaunchIdProvider.overrideWithValue((_) => true),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(goRouterProvider),
      throwsA(
        predicate(
          (error) => error.toString().contains('Override routesProvider'),
        ),
      ),
    );
  });

  testWidgets('goRouterProvider redirect runs on navigation', (tester) async {
    final container = _routerContainer();
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Router.withConfig(config: router),
      ),
    );

    router.go(RoutePaths.map);
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      RoutePaths.missingToken,
    );
  });

  testWidgets('goRouterProvider wires navigator observers', (tester) async {
    final recordingObserver = _RecordingNavigatorObserver();
    final container = ProviderContainer(
      overrides: [
        routesProvider.overrideWithValue(_testRoutes()),
        isKnownLaunchIdProvider.overrideWithValue((_) => true),
        navigatorObserversProvider.overrideWithValue([recordingObserver]),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Router.withConfig(config: router),
      ),
    );

    router.go(RoutePaths.map);
    await tester.pumpAndSettle();

    expect(recordingObserver.pushCount, greaterThan(0));
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}
