import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugAnalyticsClient', () {
    const client = DebugAnalyticsClient();

    test('logEvent completes without error', () async {
      await client.logEvent(
        const AnalyticsEvent(
          name: AnalyticsEvents.reportSubmitSuccess,
          parameters: {'launch_id': 'test-launch'},
        ),
      );
    });

    test('logScreenView completes without error', () async {
      await client.logScreenView(screenName: AnalyticsScreenNames.map);
    });

    test('setUserProperty completes without error', () async {
      await client.setUserProperty(name: 'theme', value: 'dark');
    });

    test('flush completes without error', () async {
      await client.flush();
    });
  });
}
