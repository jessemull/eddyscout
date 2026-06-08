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

  /// User exported a planned route to GPX.
  static const gpxExportSuccess = 'gpx_export_success';

  /// User imported a GPX track into route planning.
  static const gpxImportSuccess = 'gpx_import_success';

  /// GPX export failed.
  static const gpxExportFailure = 'gpx_export_failure';

  /// GPX import failed.
  static const gpxImportFailure = 'gpx_import_failure';
}
