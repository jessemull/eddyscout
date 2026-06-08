/// Canonical analytics event name constants.
abstract final class AnalyticsEvents {
  /// User successfully submitted a condition report.
  static const reportSubmitSuccess = 'report_submit_success';

  /// User exported a planned route to GPX.
  static const gpxExportSuccess = 'gpx_export_success';

  /// User imported a GPX track into route planning.
  static const gpxImportSuccess = 'gpx_import_success';

  /// GPX export failed.
  static const gpxExportFailure = 'gpx_export_failure';

  /// GPX import failed.
  static const gpxImportFailure = 'gpx_import_failure';
}
