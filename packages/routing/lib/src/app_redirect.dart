import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/src/route_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Compile-time Mapbox public token (empty in CI/tests without dart-define).
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

/// Resolves the initial route from platform and token state.
String initialAppLocation() => initialAppLocationFor(
  isWeb: kIsWeb,
  hasMapboxToken: mapboxAccessToken.isNotEmpty,
);

/// Resolves the initial route from explicit platform and token inputs.
String initialAppLocationFor({
  required bool isWeb,
  required bool hasMapboxToken,
}) {
  if (isWeb) {
    return RoutePaths.web;
  }
  if (!hasMapboxToken) {
    return RoutePaths.missingToken;
  }
  return RoutePaths.map;
}

/// Global redirect for web gating, Mapbox token checks, and invalid launch ids.
String? appRedirect(BuildContext context, GoRouterState state) =>
    resolveAppRedirect(
      location: state.matchedLocation,
      isWeb: kIsWeb,
      hasMapboxToken: mapboxAccessToken.isNotEmpty,
      isKnownLaunchId: (launchId) => launchPointById(launchId) != null,
      launchId: state.pathParameters['launchId'],
    );

/// Resolves redirect target from explicit route and platform inputs.
String? resolveAppRedirect({
  required String location,
  required bool isWeb,
  required bool hasMapboxToken,
  required bool Function(String launchId) isKnownLaunchId,
  String? launchId,
}) {
  if (isWeb) {
    if (location != RoutePaths.web) {
      return RoutePaths.web;
    }
    return null;
  }

  if (!hasMapboxToken) {
    if (location != RoutePaths.missingToken) {
      return RoutePaths.missingToken;
    }
    return null;
  }

  if (location == RoutePaths.missingToken || location == RoutePaths.web) {
    return RoutePaths.map;
  }

  if (launchId != null && !isKnownLaunchId(launchId)) {
    return RoutePaths.map;
  }

  return null;
}
