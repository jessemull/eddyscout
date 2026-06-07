import 'package:eddyscout/analytics/analytics_navigator_observer.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('AnalyticsNavigatorObserver logs screen view on push', (
    tester,
  ) async {
    final client = _RecordingAnalyticsClient();
    final router = _routerWithObserver(
      client,
      initialLocation: '/missing-token',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(
      client.screenViews,
      contains(AnalyticsScreenNames.missingMapboxToken),
    );
  });

  testWidgets('AnalyticsNavigatorObserver logs screen view on pop', (
    tester,
  ) async {
    final client = _RecordingAnalyticsClient();
    final observer = AnalyticsNavigatorObserver(client);
    final router = GoRouter(
      observers: [observer],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    client.screenViews.clear();

    final homeRoute = ModalRoute.of(tester.element(find.byType(SizedBox)));
    expect(homeRoute, isNotNull);
    observer.didPop(homeRoute!, homeRoute);
    await tester.pump();

    expect(client.screenViews, contains(AnalyticsScreenNames.map));
  });

  testWidgets('AnalyticsNavigatorObserver logs screen view on replace', (
    tester,
  ) async {
    final client = _RecordingAnalyticsClient();
    final observer = AnalyticsNavigatorObserver(client);
    final router = GoRouter(
      observers: [observer],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/missing-token',
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    client.screenViews.clear();

    final route = ModalRoute.of(tester.element(find.byType(SizedBox)));
    expect(route, isNotNull);
    observer.didReplace(newRoute: route, oldRoute: route);
    await tester.pump();

    expect(client.screenViews, contains(AnalyticsScreenNames.map));
  });
}

GoRouter _routerWithObserver(
  _RecordingAnalyticsClient client, {
  String initialLocation = '/',
}) {
  return GoRouter(
    observers: [AnalyticsNavigatorObserver(client)],
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/missing-token',
        builder: (_, _) => const SizedBox.shrink(),
      ),
    ],
    initialLocation: initialLocation,
  );
}

class _RecordingAnalyticsClient implements AnalyticsClient {
  final screenViews = <String>[];

  @override
  Future<void> flush() async {}

  @override
  Future<void> logEvent(AnalyticsEvent event) async {}

  @override
  Future<void> logScreenView({required String screenName}) async {
    screenViews.add(screenName);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {}
}
