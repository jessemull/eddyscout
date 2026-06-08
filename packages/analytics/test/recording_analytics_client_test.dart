import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('records screen views and events', () async {
    final client = RecordingAnalyticsClient();

    await client.logScreenView(screenName: 'map');
    await client.logEvent(const AnalyticsEvent(name: 'test_event'));
    await client.setUserProperty(name: 'tier', value: 'beta');
    await client.flush();

    expect(client.screenViews, ['map']);
    expect(client.events.single.name, 'test_event');
  });
}
