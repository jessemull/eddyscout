import 'package:eddyscout_core/src/app_failure.dart';
import 'package:eddyscout_core/src/gpx_failure.dart';

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
