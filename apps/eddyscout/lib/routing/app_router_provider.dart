import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Compile-time Mapbox public token (empty in CI/tests without dart-define).
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

/// Application [GoRouter] with typed routes and platform/token redirects.
final goRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: _initialLocation(),
    debugLogDiagnostics: kDebugMode,
    redirect: _redirect,
    routes: $appRoutes,
  ),
);

String _initialLocation() {
  if (kIsWeb) {
    return const WebMapPlaceholderRoute().location;
  }
  if (mapboxAccessToken.isEmpty) {
    return const MissingMapboxTokenRoute().location;
  }
  return const MapRoute().location;
}

String? _redirect(BuildContext context, GoRouterState state) {
  final location = state.matchedLocation;

  if (kIsWeb) {
    if (location != const WebMapPlaceholderRoute().location) {
      return const WebMapPlaceholderRoute().location;
    }
    return null;
  }

  if (mapboxAccessToken.isEmpty) {
    if (location != const MissingMapboxTokenRoute().location) {
      return const MissingMapboxTokenRoute().location;
    }
    return null;
  }

  if (location == const MissingMapboxTokenRoute().location ||
      location == const WebMapPlaceholderRoute().location) {
    return const MapRoute().location;
  }

  final launchId = state.pathParameters['launchId'];
  if (launchId != null && launchPointById(launchId) == null) {
    return const MapRoute().location;
  }

  return null;
}
