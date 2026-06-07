import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsScreenNames', () {
    test('maps root to map screen', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/'),
        AnalyticsScreenNames.map,
      );
    });

    test('maps launch detail paths', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/launch/willamette-park'),
        AnalyticsScreenNames.launchDetail,
      );
    });

    test('maps missing token gate', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/missing-token'),
        AnalyticsScreenNames.missingMapboxToken,
      );
    });

    test('maps web placeholder', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/web'),
        AnalyticsScreenNames.webPlaceholder,
      );
    });

    test('returns null for unknown locations', () {
      expect(AnalyticsScreenNames.fromMatchedLocation('/unknown'), isNull);
    });
  });
}
