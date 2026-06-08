import 'package:eddyscout_routing/src/route_paths.dart';
import 'package:flutter/foundation.dart';

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

/// Resolves redirect target from explicit route and platform inputs.
///
/// Unknown launch ids are handled by the launch detail route body.
String? resolveAppRedirect({
  required String location,
  required bool isWeb,
  required bool hasMapboxToken,
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

  return null;
}
