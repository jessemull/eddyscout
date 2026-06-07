import 'package:eddyscout_analytics/src/analytics_client.dart';
import 'package:eddyscout_analytics/src/analytics_event.dart';

/// In-memory [AnalyticsClient] for tests and provider overrides.
class RecordingAnalyticsClient implements AnalyticsClient {
  /// Creates an empty recording client.
  RecordingAnalyticsClient();

  /// Recorded screen views in order.
  final screenViews = <String>[];

  /// Recorded events in order.
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
