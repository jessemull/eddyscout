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

    test('returns null for launch detail paths', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/launch/willamette-park'),
        isNull,
      );
    });

    test('defines launch not-found screen name', () {
      expect(
        AnalyticsScreenNames.launchNotFound,
        'screen_launch_not_found',
      );
    });

    test('defines nearby trips search screen name', () {
      expect(
        AnalyticsScreenNames.nearbyTripsSearch,
        'screen_nearby_trips_search',
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

    test('maps saved routes list', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/saved-routes'),
        AnalyticsScreenNames.savedRoutesList,
      );
    });

    test('maps saved route detail', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/saved-routes/abc'),
        AnalyticsScreenNames.savedRouteDetail,
      );
    });

    test('maps home tab', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/home'),
        AnalyticsScreenNames.home,
      );
    });

    test('maps menu tab', () {
      expect(
        AnalyticsScreenNames.fromMatchedLocation('/menu'),
        AnalyticsScreenNames.menu,
      );
    });

    test('returns null for unknown locations', () {
      expect(AnalyticsScreenNames.fromMatchedLocation('/unknown'), isNull);
    });
  });
}
