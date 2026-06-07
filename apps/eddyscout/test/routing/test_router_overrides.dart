import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_riverpod/misc.dart';

/// Records analytics calls in tests.
class RecordingAnalyticsClient implements AnalyticsClient {
  final screenViews = <String>[];
  final events = <AnalyticsEvent>[];

  @override
  Future<void> flush() async {}

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    events.add(event);
  }

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

/// Router wiring overrides required by tests that mount the app shell.
final List<Override> appRouterTestOverrides = [
  routesProvider.overrideWithValue($appRoutes),
  isKnownLaunchIdProvider.overrideWithValue(
    (launchId) => findLaunchPointById(launchId) != null,
  ),
  navigatorObserversProvider.overrideWithValue(const []),
  analyticsClientProvider.overrideWithValue(RecordingAnalyticsClient()),
];
