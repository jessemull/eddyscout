import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LaunchDetailRoute', () {
    test('location encodes launch id', () {
      const route = LaunchDetailRoute(launchId: 'cathedral_park');

      expect(route.location, '/launch/cathedral_park');
    });
  });

  group('MapRoute', () {
    test('location is root path', () {
      expect(const MapRoute().location, RoutePaths.map);
    });
  });

  group('SavedRoutesListRoute', () {
    test('location is saved routes path', () {
      expect(
        const SavedRoutesListRoute().location,
        RoutePaths.savedRoutes,
      );
    });
  });

  group('SavedRouteDetailRoute', () {
    test('location encodes route id', () {
      const route = SavedRouteDetailRoute(routeId: 'sr_123');
      expect(route.location, '/saved-routes/sr_123');
    });
  });
}
