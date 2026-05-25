import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnalyticsEvent holds name and parameters', () {
    const event = AnalyticsEvent(
      name: 'map_opened',
      parameters: {'source': 'cold_start'},
    );
    expect(event.name, 'map_opened');
    expect(event.parameters['source'], 'cold_start');
  });
}
