import 'package:eddyscout_analytics/src/analytics_client.dart';
import 'package:eddyscout_analytics/src/debug_analytics_client.dart';
import 'package:eddyscout_analytics/src/noop_analytics_client.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_client_provider.g.dart';

/// Application-wide analytics client.
///
/// Debug builds log to console; release builds use [NoOpAnalyticsClient].
@Riverpod(keepAlive: true)
AnalyticsClient analyticsClient(Ref ref) {
  if (kDebugMode) {
    return const DebugAnalyticsClient();
  }
  return const NoOpAnalyticsClient();
}
