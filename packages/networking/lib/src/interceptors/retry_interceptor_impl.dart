import 'package:dio/dio.dart';

/// Retries transient failures with exponential backoff (see AGENTS.md).
class EddyScoutRetryInterceptor extends Interceptor {
  /// Creates an interceptor that re-issues failed requests on [dio].
  EddyScoutRetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  }) : _dio = dio;

  final Dio _dio;

  /// Maximum number of retry attempts after the initial request.
  final int maxRetries;

  /// Base delay before the first retry; doubles with each attempt.
  final Duration baseDelay;

  static const _retryCountKey = 'eddyscout_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    err.requestOptions.extra[_retryCountKey] = attempt + 1;
    final delayMs = baseDelay.inMilliseconds * (1 << attempt);
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    final status = err.response?.statusCode;
    if (status != null) {
      if (status == 429) {
        return true;
      }
      if (status >= 400 && status < 500) {
        return false;
      }
      if (status >= 500) {
        return true;
      }
    }

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown;
  }
}
