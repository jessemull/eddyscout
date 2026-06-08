import 'dart:convert' show utf8;
import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

part 'gpx_file_gateway.g.dart';

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

/// Default [GpxFileGateway] using file_picker and share_plus.
class GpxFileGatewayImpl implements GpxFileGateway {
  /// Creates a [GpxFileGatewayImpl].
  const GpxFileGatewayImpl();

  @override
  Future<Result<String, AppFailure>> pickAndReadGpx() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['gpx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return const Result.failure(
          StorageFailure(message: kGpxPickCancelledMessage),
        );
      }
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes != null) {
        return Result.success(utf8.decode(bytes));
      }
      final path = file.path;
      if (path == null) {
        return const Result.failure(
          StorageFailure(message: 'gpx_file_read_failed'),
        );
      }
      final contents = await File(path).readAsString();
      return Result.success(contents);
    } on Object catch (e, st) {
      return Result.failure(
        StorageFailure(message: 'gpx_read_failed', stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void, AppFailure>> writeAndShareGpx({
    required String filename,
    required String gpxXml,
  }) async {
    try {
      final bytes = utf8.encode(gpxXml);
      final XFile xFile;
      if (kIsWeb) {
        xFile = XFile.fromData(
          bytes,
          name: filename,
          mimeType: 'application/gpx+xml',
        );
      } else {
        final path = await _writeTempFile(filename: filename, contents: gpxXml);
        if (path == null) {
          return const Result.failure(
            StorageFailure(message: 'gpx_file_write_failed'),
          );
        }
        xFile = XFile(path, mimeType: 'application/gpx+xml');
      }

      final shareResult = await SharePlatform.instance.share(
        ShareParams(
          files: [xFile],
          subject: 'EddyScout route',
        ),
      );

      return switch (shareResult.status) {
        ShareResultStatus.unavailable => const Result.failure(
          StorageFailure(message: 'gpx_share_failed'),
        ),
        ShareResultStatus.success ||
        ShareResultStatus.dismissed => const Result.success(null),
      };
    } on Object catch (e, st) {
      return Result.failure(
        StorageFailure(message: 'gpx_share_failed', stackTrace: st),
      );
    }
  }

  Future<String?> _writeTempFile({
    required String filename,
    required String contents,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(contents);
      return file.path;
    } on Object {
      return null;
    }
  }
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

/// Default platform [GpxFileGateway] for GPX pick/share flows.
@Riverpod(keepAlive: true)
GpxFileGateway gpxFileGateway(Ref ref) => const GpxFileGatewayImpl();
