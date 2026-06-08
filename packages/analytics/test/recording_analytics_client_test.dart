import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecordingAnalyticsClient', () {
    test(
      'records events, screen views, and completes side-effect methods',
      () async {
        final client = RecordingAnalyticsClient();
        const event = AnalyticsEvent(
          name: AnalyticsEvents.reportSubmitSuccess,
          parameters: {'launch_id': 'cathedral_park'},
        );

        await client.logEvent(event);
        await client.logScreenView(
          screenName: AnalyticsScreenNames.launchDetail,
        );
        await client.setUserProperty(name: 'skill', value: 'intermediate');
        await client.flush();

        expect(client.events, [event]);
        expect(client.screenViews, [AnalyticsScreenNames.launchDetail]);
      },
    );
  });
}
