/// Machine-readable failures for GPX parse/serialize and file flows.
///
/// UI must localize these via generated localization strings.
enum GpxFailureCode {
  /// Input string is empty or whitespace only.
  emptyInput,

  /// XML could not be parsed as GPX.
  malformedXml,

  /// No track, route, or usable waypoint sequence.
  noGeometry,

  /// Fewer than two coordinate points.
  tooFewPoints,

  /// No active route polyline to export.
  noRouteToExport,

  /// Local file could not be read.
  fileReadFailed,

  /// Temp file could not be written.
  fileWriteFailed,

  /// System share sheet failed.
  shareFailed,
}

/// Typed GPX failure for result boundaries.
final class GpxFailure {
  /// Creates a [GpxFailure] with [code].
  const GpxFailure({required this.code});

  /// Failure category for localization and analytics.
  final GpxFailureCode code;
}
