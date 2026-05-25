import 'package:dio/dio.dart';
import 'package:eddyscout_networking/src/dio_factory.dart';
import 'package:eddyscout_networking/src/interceptors/logging_interceptor_impl.dart';
import 'package:eddyscout_networking/src/interceptors/retry_interceptor_impl.dart';

/// Default [DioFactory] for public conditions APIs (NWS, NOAA, USGS).
class EddyScoutDioFactory implements DioFactory {
  /// Creates a factory with optional debug logging and retry tuning.
  const EddyScoutDioFactory({
    this.userAgent = defaultUserAgent,
    this.enableDebugLogging = false,
    this.maxRetries = 3,
    this.retryBaseDelay = const Duration(milliseconds: 500),
  });

  /// User-Agent sent on every conditions HTTP request.
  static const defaultUserAgent = 'EddyScout/1.0 (eddyscout; conditions)';

  /// Value for the `User-Agent` header.
  final String userAgent;

  /// When true, logs request/response metadata via [EddyScoutLoggingInterceptor].
  final bool enableDebugLogging;

  /// Maximum retry attempts for transient failures.
  final int maxRetries;

  /// Base delay before the first retry; doubles per attempt.
  final Duration retryBaseDelay;

  @override
  Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: DioFactory.connectTimeout,
        receiveTimeout: DioFactory.receiveTimeout,
        sendTimeout: DioFactory.sendTimeout,
        headers: <String, String>{
          'User-Agent': userAgent,
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      EddyScoutRetryInterceptor(
        dio: dio,
        maxRetries: maxRetries,
        baseDelay: retryBaseDelay,
      ),
    );

    if (enableDebugLogging) {
      dio.interceptors.add(EddyScoutLoggingInterceptor());
    }

    return dio;
  }
}
