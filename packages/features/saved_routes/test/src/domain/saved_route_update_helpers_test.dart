import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/domain/saved_route_update_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

SavedRoute _sampleRoute({
  List<RouteWaypoint> waypoints = const [
    RouteWaypoint.catalog(launchId: 'a', order: 0),
    RouteWaypoint.catalog(launchId: 'b', order: 1),
  ],
}) {
  final now = DateTime.utc(2026);
  return SavedRoute(
    id: 'r1',
    name: 'Sample',
    waypoints: waypoints,
    metadata: const SavedRouteMetadata(),
    geometrySnapshot: RouteGeometrySnapshot(
      polylineLonLat: const [
        [-122.6, 45.5],
        [-122.5, 45.6],
      ],
      lengthMeters: 1000,
      computedAt: now,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('savedRouteWaypointsChanged is false when order matches', () {
    final route = _sampleRoute();
    expect(
      savedRouteWaypointsChanged(route, route.waypoints),
      isFalse,
    );
  });

  test('savedRouteWaypointsChanged is true when launch order changes', () {
    final route = _sampleRoute();
    expect(
      savedRouteWaypointsChanged(
        route,
        const [
          RouteWaypoint.catalog(launchId: 'b', order: 0),
          RouteWaypoint.catalog(launchId: 'a', order: 1),
        ],
      ),
      isTrue,
    );
  });

  test('savedRouteWaypointsChanged is true when count changes', () {
    final route = _sampleRoute();
    expect(
      savedRouteWaypointsChanged(
        route,
        const [
          RouteWaypoint.catalog(launchId: 'a', order: 0),
        ],
      ),
      isTrue,
    );
  });
}
