import 'package:eddyscout/routing/app_routes.dart';
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
      expect(const MapRoute().location, '/');
    });
  });
}
