import 'package:eddyscout_analytics/src/analytics_client.dart';
import 'package:eddyscout_analytics/src/analytics_event.dart';
import 'package:flutter/foundation.dart';

/// Logs analytics to the console in debug mode only.
class DebugAnalyticsClient implements AnalyticsClient {
  /// Creates a debug analytics client.
  const DebugAnalyticsClient();

  static const _prefix = '[eddyscout.analytics]';

  @override
  Future<void> flush() async {
    if (kDebugMode) {
      debugPrint('$_prefix flush');
    }
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (kDebugMode) {
      debugPrint('$_prefix event: $event');
    }
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    if (kDebugMode) {
      debugPrint('$_prefix screen: $screenName');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (kDebugMode) {
      debugPrint('$_prefix user_property: $name=$value');
    }
  }
}
