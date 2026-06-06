import 'package:eddyscout/routing/app_router_provider.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('unknownLaunchRedirect sends missing launch ids to map', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(_unknownLaunchRedirectProbe('unknown_launch')),
      const MapRoute().location,
    );
    expect(
      container.read(_unknownLaunchRedirectProbe('cathedral_park')),
      isNull,
    );
    expect(container.read(_unknownLaunchRedirectProbe(null)), isNull);
  });
}

final Provider<String?> Function(String?) _unknownLaunchRedirectProbe =
    Provider.family<String?, String?>(unknownLaunchRedirect);
