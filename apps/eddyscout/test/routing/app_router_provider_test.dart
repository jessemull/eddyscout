import 'package:eddyscout/routing/app_router_provider.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('goRouterProvider initial location without Mapbox token', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);
    expect(
      router.routeInformationProvider.value.uri.path,
      const MissingMapboxTokenRoute().location,
    );
  });

  test('LaunchDetailRoute encodes launch id in path', () {
    expect(
      const LaunchDetailRoute(launchId: 'cathedral_park').location,
      '/launch/cathedral_park',
    );
  });
}
