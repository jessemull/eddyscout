import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Compile-time Mapbox public token (empty in CI/tests without dart-define).
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

/// Mapbox token for routing gates; override in tests via [ProviderContainer].
final mapboxAccessTokenProvider = Provider<String>((ref) => mapboxAccessToken);

/// Application [GoRouter] with typed routes and platform/token redirects.
final goRouterProvider = Provider<GoRouter>(
  (ref) {
    final token = ref.watch(mapboxAccessTokenProvider);
    return GoRouter(
      initialLocation: _initialLocation(token),
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) => _redirect(ref, state),
      routes: $appRoutes,
    );
  },
);

String _initialLocation(String token) {
  if (kIsWeb) {
    return const WebMapPlaceholderRoute().location;
  }
  if (token.isEmpty) {
    return const MissingMapboxTokenRoute().location;
  }
  return const MapRoute().location;
}

String? _redirect(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;
  final token = ref.read(mapboxAccessTokenProvider);

  if (kIsWeb) {
    if (location != const WebMapPlaceholderRoute().location) {
      return const WebMapPlaceholderRoute().location;
    }
    return null;
  }

  if (token.isEmpty) {
    if (location != const MissingMapboxTokenRoute().location) {
      return const MissingMapboxTokenRoute().location;
    }
    return null;
  }

  if (location == const MissingMapboxTokenRoute().location ||
      location == const WebMapPlaceholderRoute().location) {
    return const MapRoute().location;
  }

  final launchRedirect = unknownLaunchRedirect(
    ref,
    state.pathParameters['launchId'],
  );
  if (launchRedirect != null) {
    return launchRedirect;
  }

  return null;
}

/// Redirect target when [launchId] is absent from the curated catalog.
@visibleForTesting
String? unknownLaunchRedirect(Ref ref, String? launchId) {
  if (launchId != null && ref.readLaunchPointIfExists(launchId) == null) {
    return const MapRoute().location;
  }
  return null;
}
