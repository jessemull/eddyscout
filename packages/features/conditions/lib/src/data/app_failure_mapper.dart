import 'package:dio/dio.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Maps transport and platform errors to [AppFailure] for package boundaries.
AppFailure mapToAppFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppFailure) {
    return error;
  }
  if (error is DioException) {
    if (error.type == DioExceptionType.cancel) {
      return NetworkFailure(
        message: 'Request was cancelled.',
        stackTrace: stackTrace ?? error.stackTrace,
      );
    }
    final status = error.response?.statusCode;
    if (status != null && status >= 500) {
      return NetworkFailure(
        message: 'Server error ($status). Try again later.',
        stackTrace: stackTrace ?? error.stackTrace,
        statusCode: status,
      );
    }
    return NetworkFailure(
      message: 'Network request failed. Check your connection.',
      stackTrace: stackTrace ?? error.stackTrace,
      statusCode: status,
    );
  }
  final msg = error.toString().toLowerCase();
  if (msg.contains('socket') ||
      msg.contains('network') ||
      msg.contains('connection')) {
    return NetworkFailure(
      message: 'Could not reach the service. Check your connection.',
      stackTrace: stackTrace,
    );
  }
  return UnexpectedFailure(
    message: 'Something went wrong. Try again later.',
    stackTrace: stackTrace,
  );
}
