import 'package:dio/dio.dart';

/// Factory for creating configured [Dio] instances.
///
/// Implementations should add interceptors in the correct order:
/// 1. Auth (adds tokens)
/// 2. Retry (handles transient failures)
/// 3. Error normalizing (maps DioExceptions to domain failures)
/// 4. Logging (last, so it sees final request/response)
abstract class DioFactory {
  /// Creates a [Dio] instance with all interceptors configured.
  Dio create();

  /// Default connect timeout.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Default receive timeout.
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Default send timeout.
  static const Duration sendTimeout = Duration(seconds: 15);
}
