/// Stable screen-view names for go_router matched locations.
abstract final class AnalyticsScreenNames {
  /// Map screen (root route).
  static const map = 'screen_map';

  /// Launch detail screen.
  static const launchDetail = 'screen_launch_detail';

  /// Unknown launch id on a launch detail deep link.
  static const launchNotFound = 'screen_launch_not_found';

  /// Missing Mapbox token gate.
  static const missingMapboxToken = 'screen_missing_mapbox_token';

  /// Web map placeholder.
  static const webPlaceholder = 'screen_web_placeholder';

  /// Maps a go_router [matchedLocation] to a screen name, or null when unknown.
  ///
  /// `/launch/:id` paths return null because the matched location cannot
  /// distinguish launch detail from launch-not-found; the app route body logs
  /// [launchDetail] or [launchNotFound] when the async launch resolves.
  static String? fromMatchedLocation(String matchedLocation) {
    if (matchedLocation == '/') {
      return map;
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
