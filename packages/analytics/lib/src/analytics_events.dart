/// Canonical analytics event name constants.
abstract final class AnalyticsEvents {
  /// User successfully submitted a condition report.
  static const reportSubmitSuccess = 'report_submit_success';

  /// User saved a new planned route locally.
  static const savedRouteCreateSuccess = 'saved_route_create_success';

  /// User updated a saved route.
  static const savedRouteUpdateSuccess = 'saved_route_update_success';

  /// User deleted a saved route.
  static const savedRouteDeleteSuccess = 'saved_route_delete_success';

  /// User loaded a saved route onto the map.
  static const savedRouteLoadOnMap = 'saved_route_load_on_map';
}
