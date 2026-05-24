import 'package:eddyscout_analytics/src/analytics_event.dart';

/// Abstraction over analytics providers.
///
/// Implementations must NEVER include PII in event parameters.
/// See docs/ANALYTICS.md for naming conventions and privacy rules.
abstract class AnalyticsClient {
  /// Log a named event.
  Future<void> logEvent(AnalyticsEvent event);

  /// Track a screen view.
  Future<void> logScreenView({required String screenName});

  /// Set a user property (must not contain PII).
  Future<void> setUserProperty({required String name, required String value});

  /// Flush any queued events.
  Future<void> flush();
}
