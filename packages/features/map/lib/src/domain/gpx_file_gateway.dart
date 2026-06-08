import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';

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

/// Maps file-gateway [AppFailure] values to [GpxFailureCode] when possible.
GpxFailureCode gpxFailureCodeFromAppFailure(AppFailure failure) {
  if (failure is StorageFailure) {
    return switch (failure.message) {
      'gpx_file_read_failed' ||
      'gpx_read_failed' => GpxFailureCode.fileReadFailed,
      'gpx_file_write_failed' => GpxFailureCode.fileWriteFailed,
      'gpx_share_failed' => GpxFailureCode.shareFailed,
      _ => GpxFailureCode.fileReadFailed,
    };
  }
  return GpxFailureCode.fileReadFailed;
}
