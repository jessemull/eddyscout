/// Stable screen-view names for go_router matched locations.
abstract final class AnalyticsScreenNames {
  /// Map screen (root route).
  static const map = 'screen_map';

  /// Launch detail screen.
  static const launchDetail = 'screen_launch_detail';

  /// Nearby trips search (nested under launch detail).
  static const nearbyTripsSearch = 'screen_nearby_trips_search';

  /// Unknown launch id on a launch detail deep link.
  static const launchNotFound = 'screen_launch_not_found';

  /// Missing Mapbox token gate.
  static const missingMapboxToken = 'screen_missing_mapbox_token';

  /// Web map placeholder.
  static const webPlaceholder = 'screen_web_placeholder';

  /// Saved routes list tab.
  static const savedRoutesList = 'screen_saved_routes_list';

  /// Home placeholder tab.
  static const home = 'screen_home';

  /// Menu tab.
  static const menu = 'screen_menu';

  /// Saved route detail screen.
  static const savedRouteDetail = 'screen_saved_route_detail';

  /// Maps a go_router [matchedLocation] to a screen name, or null when unknown.
  ///
  /// `/launch/:id` paths return null because the matched location cannot
  /// distinguish launch detail from launch-not-found; the app route body logs
  /// [launchDetail] or [launchNotFound] when the async launch resolves.
  static String? fromMatchedLocation(String matchedLocation) {
    if (matchedLocation == '/') {
      return map;
    }
    if (matchedLocation == '/home') {
      return home;
    }
    if (matchedLocation == '/menu') {
      return menu;
    }
    if (matchedLocation == '/missing-token') {
      return missingMapboxToken;
    }
    if (matchedLocation == '/web') {
      return webPlaceholder;
    }
    if (matchedLocation == '/saved-routes') {
      return savedRoutesList;
    }
    if (matchedLocation.startsWith('/saved-routes/')) {
      return savedRouteDetail;
    }
    return null;
  }
}
