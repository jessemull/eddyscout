import 'package:eddyscout/routing/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('typed routes encode canonical locations', () {
    expect(const MapRoute().location, '/');
    expect(
      const LaunchDetailRoute(launchId: 'cathedral_park').location,
      '/launch/cathedral_park',
    );
    expect(const MissingMapboxTokenRoute().location, '/missing-token');
    expect(const WebMapPlaceholderRoute().location, '/web');
  });
}
