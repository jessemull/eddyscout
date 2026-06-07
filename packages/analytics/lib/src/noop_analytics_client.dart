import 'package:eddyscout_analytics/src/analytics_client.dart';
import 'package:eddyscout_analytics/src/analytics_event.dart';

/// Analytics client that discards all events.
///
/// Used in release builds and tests when telemetry must not leave the device.
class NoOpAnalyticsClient implements AnalyticsClient {
  /// Creates a no-op analytics client.
  const NoOpAnalyticsClient();

  @override
  Future<void> flush() async {}

  @override
  Future<void> logEvent(AnalyticsEvent event) async {}

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {}
}
