/// Canonical path strings for app routes.
///
/// Typed routes in the app shell reference these constants so redirect logic
/// in this package stays aligned with go_router_builder route definitions.
abstract final class RoutePaths {
  /// Map screen (root).
  static const map = '/';

  /// Launch detail with `:launchId` path parameter.
  static const launchDetail = '/launch/:launchId';

  /// Shown when `MAPBOX_ACCESS_TOKEN` is missing on mobile/desktop.
  static const missingToken = '/missing-token';

  /// Web placeholder when the map is unavailable on web.
  static const web = '/web';
}
