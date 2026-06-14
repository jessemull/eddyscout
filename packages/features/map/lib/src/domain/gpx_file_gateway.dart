import 'package:eddyscout_core/eddyscout_core.dart';

/// User dismissed the GPX file picker without choosing a file.
const kGpxPickCancelledMessage = 'gpx_pick_cancelled';

/// Platform file pick and share for GPX import/export.
abstract class GpxFileGateway {
  /// Opens a file picker and returns GPX XML text.
  Future<Result<String, AppFailure>> pickAndReadGpx();

  /// Writes [gpxXml] to a temp file and opens the system share sheet.
  Future<Result<void, AppFailure>> writeAndShareGpx({
    required String filename,
    required String gpxXml,
  });
}
