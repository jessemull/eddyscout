import 'dart:convert';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteWaypoint JSON', () {
    test('parses legacy catalog rows without type field', () {
      const legacy = {'launchId': 'cathedral_park', 'order': 0};

      final waypoint = RouteWaypoint.fromJson(legacy);

      expect(waypoint, isA<CatalogRouteWaypoint>());
      expect(waypoint.launchId, 'cathedral_park');
      expect(waypoint.order, 0);
    });

    test('round-trips snap variant', () {
      const waypoint = RouteWaypoint.snap(
        latitude: 45.5123,
        longitude: -122.6789,
        order: 1,
        label: 'Mid-river stop',
      );

      final decoded = RouteWaypoint.fromJson(
        jsonDecode(jsonEncode(waypoint.toJson())) as Map<String, dynamic>,
      );

      expect(decoded, isA<SnapRouteWaypoint>());
      expect(decoded.order, 1);
      expect(
        decoded,
        const RouteWaypoint.snap(
          latitude: 45.5123,
          longitude: -122.6789,
          order: 1,
          label: 'Mid-river stop',
        ),
      );
    });
  });

  group('routeWaypointFromPlanningStop', () {
    test('maps catalog and snap stops', () {
      const launch = LaunchPoint(
        id: 'a',
        name: 'Launch A',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );

      final catalog = routeWaypointFromPlanningStop(
        const RoutePlanningStop.catalog(launch),
        0,
      );
      final snap = routeWaypointFromPlanningStop(
        const RoutePlanningStop.snap(
          id: 'snap_1',
          latitude: 45.51,
          longitude: -122.61,
          label: 'Custom stop',
        ),
        1,
      );

      expect(catalog, isA<CatalogRouteWaypoint>());
      expect(catalog.launchId, 'a');
      expect(snap, isA<SnapRouteWaypoint>());
      expect((snap as SnapRouteWaypoint).label, 'Custom stop');
    });
  });

  group('RoutePlanningStopX', () {
    test('sameStopAs detects duplicate catalog and snap stops', () {
      const launch = LaunchPoint(
        id: 'a',
        name: 'Launch A',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );
      const stopA = RoutePlanningStop.catalog(launch);
      const stopB = RoutePlanningStop.catalog(launch);
      const snapA = RoutePlanningStop.snap(
        id: 's1',
        latitude: 45.51,
        longitude: -122.61,
        label: 'Pin',
      );
      const snapNear = RoutePlanningStop.snap(
        id: 's2',
        latitude: 45.5100001,
        longitude: -122.6100001,
        label: 'Pin 2',
      );

      expect(stopA.sameStopAs(stopB), isTrue);
      expect(snapA.sameStopAs(snapNear), isTrue);
      expect(stopA.sameStopAs(snapA), isFalse);
    });
  });
}
