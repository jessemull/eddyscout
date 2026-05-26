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

  /// Parses a `Retry-After` header value into a delay duration.
  ///
  /// Supports:
  /// - delta-seconds: `Retry-After: 120`
  /// - ISO-8601 date strings (best-effort): `Retry-After: 2026-01-01T00:00:00Z`
  static Duration? parseRetryAfter({
    required String value,
    required DateTime now,
  }) {
    final seconds = int.tryParse(value.trim());
    if (seconds != null) {
      return Duration(seconds: seconds);
    }
    final date = DateTime.tryParse(value);
    if (date != null) {
      final diff = date.difference(now);
      return diff.isNegative ? Duration.zero : diff;
    }
    return null;
  }

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
    final delay = _retryDelay(err, attempt);
    final cancelToken = err.requestOptions.cancelToken;
    if (delay > Duration.zero) {
      if (cancelToken != null) {
        await Future.any<void>([
          Future<void>.delayed(delay),
          cancelToken.whenCancel,
        ]);
        if (cancelToken.isCancelled) {
          handler.next(err);
          return;
        }
      } else {
        await Future<void>.delayed(delay);
      }
    }

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Duration _retryDelay(DioException err, int attempt) {
    final status = err.response?.statusCode;
    if (status == 429) {
      final raw = err.response?.headers.value('retry-after');
      if (raw != null) {
        final parsed = parseRetryAfter(value: raw, now: DateTime.now());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    final delayMs = baseDelay.inMilliseconds * (1 << attempt);
    return Duration(milliseconds: delayMs);
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
