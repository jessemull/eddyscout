import 'package:eddyscout_routing/src/app_redirect.dart';
import 'package:eddyscout_routing/src/router_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App route list supplied by the composition root via [ProviderScope]
/// override.
final routesProvider = Provider<List<RouteBase>>(
  (ref) => throw UnimplementedError(
    'Override routesProvider with app route list in ProviderScope',
  ),
);

/// Launch id validation supplied by the composition root via [ProviderScope]
/// override.
final isKnownLaunchIdProvider = Provider<bool Function(String launchId)>(
  (ref) => throw UnimplementedError(
    'Override isKnownLaunchIdProvider in ProviderScope',
  ),
);

/// Mapbox token for routing gates; override in tests via [ProviderContainer].
final mapboxAccessTokenProvider = Provider<String>((ref) => mapboxAccessToken);

/// Application [GoRouter] with typed routes and platform/token redirects.
final goRouterProvider = Provider<GoRouter>(
  (ref) {
    final token = ref.watch(mapboxAccessTokenProvider);
    final isKnownLaunchId = ref.watch(isKnownLaunchIdProvider);
    return createRouter(
      routes: ref.watch(routesProvider),
      initialLocation: initialAppLocationFor(
        isWeb: kIsWeb,
        hasMapboxToken: token.isNotEmpty,
      ),
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) => resolveAppRedirect(
        location: state.matchedLocation,
        isWeb: kIsWeb,
        hasMapboxToken: token.isNotEmpty,
        isKnownLaunchId: isKnownLaunchId,
        launchId: state.pathParameters['launchId'],
      ),
    );
  },
);
