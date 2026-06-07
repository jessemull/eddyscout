import 'package:eddyscout_routing/src/app_redirect.dart' as app_redirect;
import 'package:eddyscout_routing/src/router_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router_provider.g.dart';

/// App route list supplied by the composition root via [ProviderScope]
/// override.
@Riverpod(keepAlive: true)
List<RouteBase> routes(Ref ref) {
  throw UnimplementedError(
    'Override routesProvider with app route list in ProviderScope',
  );
}

/// Launch id validation supplied by the composition root via [ProviderScope]
/// override.
@Riverpod(keepAlive: true)
bool Function(String launchId) isKnownLaunchId(Ref ref) {
  throw UnimplementedError(
    'Override isKnownLaunchIdProvider in ProviderScope',
  );
}

/// Navigator observers supplied by the app composition root.
@Riverpod(keepAlive: true)
List<NavigatorObserver> navigatorObservers(Ref ref) => const [];

/// Mapbox token for routing gates; override in tests via [ProviderContainer].
@Riverpod(keepAlive: true)
String mapboxAccessToken(Ref ref) => app_redirect.mapboxAccessToken;

/// Application [GoRouter] with typed routes and platform/token redirects.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final token = ref.watch(mapboxAccessTokenProvider);
  final isKnownLaunchIdFn = ref.watch(isKnownLaunchIdProvider);
  return createRouter(
    routes: ref.watch(routesProvider),
    initialLocation: app_redirect.initialAppLocationFor(
      isWeb: kIsWeb,
      hasMapboxToken: token.isNotEmpty,
    ),
    debugLogDiagnostics: kDebugMode,
    observers: ref.watch(navigatorObserversProvider),
    redirect: (context, state) => app_redirect.resolveAppRedirect(
      location: state.matchedLocation,
      isWeb: kIsWeb,
      hasMapboxToken: token.isNotEmpty,
      isKnownLaunchId: isKnownLaunchIdFn,
      launchId: state.pathParameters['launchId'],
    ),
  );
}
