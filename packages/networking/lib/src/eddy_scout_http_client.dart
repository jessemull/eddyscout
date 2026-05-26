import 'package:dio/dio.dart';
import 'package:eddyscout_networking/src/eddy_scout_dio_factory.dart';
import 'package:eddyscout_networking/src/eddy_scout_http_response.dart';

/// Shared HTTP client for public conditions APIs (NWS, NOAA, USGS, Open-Meteo).
///
/// Backed by [Dio] from [EddyScoutDioFactory] with retry and optional debug
/// logging.
class EddyScoutHttpClient {
  /// Creates a client with optional [dio], [requestTimeout], and debug logging.
  EddyScoutHttpClient({
    Dio? dio,
    this.requestTimeout = const Duration(seconds: 18),
    bool enableDebugLogging = false,
  }) : _dio =
           dio ??
           EddyScoutDioFactory(enableDebugLogging: enableDebugLogging).create();

  /// User-Agent sent on every request (NWS and USGS policy).
  static const String userAgent = EddyScoutDioFactory.defaultUserAgent;

  final Dio _dio;

  /// Per-request receive timeout for conditions fetches.
  final Duration requestTimeout;

  /// GET [uri] and return status code plus plain-text body.
  Future<EddyScoutHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<String>(
      uri.toString(),
      options: Options(
        headers: headers,
        receiveTimeout: requestTimeout,
        responseType: ResponseType.plain,
      ),
      cancelToken: cancelToken,
    );
    return EddyScoutHttpResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data ?? '',
    );
  }

  /// NWS prefers `application/geo+json` for api.weather.gov.
  Future<EddyScoutHttpResponse> getNws(
    Uri uri, {
    CancelToken? cancelToken,
  }) => get(
    uri,
    headers: {'Accept': 'application/geo+json'},
    cancelToken: cancelToken,
  );

  /// GET [uri] as JSON; returns null on non-2xx or transport errors.
  Future<Map<String, dynamic>?> getJson(
    Uri uri, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        uri.toString(),
        options: Options(
          receiveTimeout: requestTimeout,
          responseType: ResponseType.json,
        ),
        cancelToken: cancelToken,
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        return null;
      }
      return _decodeJsonMap(response.data);
    } on DioException {
      return null;
    }
  }

  /// NWS GET with geo+json Accept; null on failure like [getJson].
  Future<Map<String, dynamic>?> getNwsJson(
    Uri uri, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        uri.toString(),
        options: Options(
          headers: {'Accept': 'application/geo+json'},
          receiveTimeout: requestTimeout,
          responseType: ResponseType.json,
        ),
        cancelToken: cancelToken,
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        return null;
      }
      return _decodeJsonMap(response.data);
    } on DioException {
      return null;
    }
  }

  Map<String, dynamic>? _decodeJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// Closes the underlying [Dio] instance.
  void close() {
    _dio.close(force: true);
  }
}
