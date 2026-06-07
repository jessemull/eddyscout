/// Stable screen-view names for go_router matched locations.
abstract final class AnalyticsScreenNames {
  /// Map screen (root route).
  static const map = 'screen_map';

  /// Launch detail screen.
  static const launchDetail = 'screen_launch_detail';

  /// Missing Mapbox token gate.
  static const missingMapboxToken = 'screen_missing_mapbox_token';

  /// Web map placeholder.
  static const webPlaceholder = 'screen_web_placeholder';

  /// Maps a go_router [matchedLocation] to a screen name, or null when unknown.
  static String? fromMatchedLocation(String matchedLocation) {
    if (matchedLocation == '/') {
      return map;
    }
    if (matchedLocation.startsWith('/launch/')) {
      return launchDetail;
    }
    if (matchedLocation == '/missing-token') {
      return missingMapboxToken;
    }
    if (matchedLocation == '/web') {
      return webPlaceholder;
    }
    return null;
  }
}
