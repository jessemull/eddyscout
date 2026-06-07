import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoOpAnalyticsClient', () {
    const client = NoOpAnalyticsClient();

    test('logEvent completes without error', () async {
      await client.logEvent(const AnalyticsEvent(name: 'test_event'));
    });

    test('logScreenView completes without error', () async {
      await client.logScreenView(screenName: AnalyticsScreenNames.map);
    });

    test('setUserProperty completes without error', () async {
      await client.setUserProperty(name: 'skill', value: 'beginner');
    });

    test('flush completes without error', () async {
      await client.flush();
    });
  });
}
