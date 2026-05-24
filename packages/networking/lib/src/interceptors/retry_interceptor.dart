import 'package:dio/dio.dart';

/// Retries failed requests with exponential backoff.
///
/// Only retries on network errors and 5xx status codes.
/// Never retries on 4xx (client errors) or cancellations.
abstract class RetryInterceptor extends Interceptor {
  /// Maximum number of retry attempts. Default: 3.
  int get maxRetries => 3;
}
