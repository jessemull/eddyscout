import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:dio/dio.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Maps transport and platform errors to [AppFailure] for package boundaries.
AppFailure mapToAppFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppFailure) {
    return error;
  }
  if (error is FirebaseFunctionsException) {
    return _mapFirebaseFunctionsException(error, stackTrace);
  }
  if (error is FirebaseAuthException) {
    return UnexpectedFailure(
      message: error.message ?? 'Authentication failed. Restart the app.',
      stackTrace: stackTrace,
    );
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

AppFailure _mapFirebaseFunctionsException(
  FirebaseFunctionsException error,
  StackTrace? stackTrace,
) {
  final code = error.code.toLowerCase();
  if (code == 'unauthenticated') {
    return NetworkFailure(
      message:
          'Authentication required (unauthenticated). '
          'Restart the app and try again.',
      stackTrace: stackTrace,
    );
  }
  if (code == 'unavailable' || code == 'deadline-exceeded') {
    return NetworkFailure(
      message: 'Cloud service unavailable. Try again later.',
      stackTrace: stackTrace,
    );
  }
  final detail = error.message?.trim();
  if (detail != null && detail.isNotEmpty) {
    return UnexpectedFailure(message: detail, stackTrace: stackTrace);
  }
  return UnexpectedFailure(
    message: 'Cloud request failed ($code). Try again later.',
    stackTrace: stackTrace,
  );
}
