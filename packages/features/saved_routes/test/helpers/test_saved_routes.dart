import 'package:eddyscout_core/eddyscout_core.dart';

/// Sample saved route for widget and repository tests.
SavedRoute testSavedRoute({
  String id = 'sr_test',
  String name = 'Test Route',
  bool isFavorite = false,
  double? distanceMeters = 5200,
}) {
  final now = DateTime.utc(2026);
  return SavedRoute(
    id: id,
    name: name,
    isFavorite: isFavorite,
    waypoints: const [
      RouteWaypoint.catalog(launchId: 'launch-a', order: 0),
      RouteWaypoint.catalog(launchId: 'launch-b', order: 1),
    ],
    metadata: SavedRouteMetadata(distanceMeters: distanceMeters),
    createdAt: now,
    updatedAt: now,
  );
}
