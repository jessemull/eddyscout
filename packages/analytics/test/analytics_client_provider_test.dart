import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('analyticsClientProvider returns DebugAnalyticsClient in tests', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final client = container.read(analyticsClientProvider);
    expect(client, isA<DebugAnalyticsClient>());
  });
}
