import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecordingAnalyticsClient', () {
    test('records screen views and events in order', () async {
      final client = RecordingAnalyticsClient();

      await client.logScreenView(screenName: AnalyticsScreenNames.map);
      await client.logEvent(
        const AnalyticsEvent(
          name: AnalyticsEvents.reportSubmitSuccess,
          parameters: {'launch_id': 'test-launch'},
        ),
      );
      await client.setUserProperty(name: 'skill', value: 'beginner');
      await client.flush();

      expect(client.screenViews, [AnalyticsScreenNames.map]);
      expect(client.events, hasLength(1));
      expect(client.events.single.name, AnalyticsEvents.reportSubmitSuccess);
    });
  });
}
