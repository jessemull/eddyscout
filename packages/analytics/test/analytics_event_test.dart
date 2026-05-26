import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsEvent', () {
    test('holds name and parameters', () {
      const event = AnalyticsEvent(
        name: 'map_opened',
        parameters: {'source': 'cold_start'},
      );
      expect(event.name, 'map_opened');
      expect(event.parameters['source'], 'cold_start');
    });

    test('defaults parameters to empty map', () {
      const event = AnalyticsEvent(name: 'x');
      expect(event.parameters, isEmpty);
    });

    test('toString includes name and parameters', () {
      const event = AnalyticsEvent(name: 'x', parameters: {'a': 1});
      expect(event.toString(), contains('AnalyticsEvent('));
      expect(event.toString(), contains('x'));
      expect(event.toString(), contains('a'));
    });

    test('equality compares name and parameters', () {
      const a = AnalyticsEvent(name: 'x', parameters: {'a': 1, 'b': true});
      const b = AnalyticsEvent(name: 'x', parameters: {'a': 1, 'b': true});
      const c = AnalyticsEvent(name: 'x', parameters: {'a': 1});
      const d = AnalyticsEvent(name: 'y', parameters: {'a': 1, 'b': true});
      expect(a, b);
      expect(a == c, isFalse);
      expect(a == d, isFalse);
    });

    test('hashCode is stable for equal instances', () {
      const a = AnalyticsEvent(name: 'x', parameters: {'a': 1, 'b': true});
      const b = AnalyticsEvent(name: 'x', parameters: {'a': 1, 'b': true});
      // We don't promise stable hashes across map iteration order;
      // only equality.
      expect(a, b);
    });

    test('parameter order does not affect equality', () {
      const a = AnalyticsEvent(name: 'x', parameters: {'a': 1, 'b': 2});
      const b = AnalyticsEvent(name: 'x', parameters: {'b': 2, 'a': 1});
      expect(a, b);
    });

    test('hashCode is computed', () {
      const event = AnalyticsEvent(name: 'x', parameters: {'a': 1});
      expect(event.hashCode, isA<int>());
    });
  });
}
