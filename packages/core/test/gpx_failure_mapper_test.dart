import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gpxFailureCodeFromAppFailure', () {
    test('maps known storage messages', () {
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_file_read_failed'),
        ),
        GpxFailureCode.fileReadFailed,
      );
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_file_write_failed'),
        ),
        GpxFailureCode.fileWriteFailed,
      );
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_share_failed'),
        ),
        GpxFailureCode.shareFailed,
      );
    });

    test('defaults unknown storage messages to fileReadFailed', () {
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'other'),
        ),
        GpxFailureCode.fileReadFailed,
      );
    });

    test('defaults non-storage failures to fileReadFailed', () {
      expect(
        gpxFailureCodeFromAppFailure(const NetworkFailure(message: 'offline')),
        GpxFailureCode.fileReadFailed,
      );
    });
  });
}
