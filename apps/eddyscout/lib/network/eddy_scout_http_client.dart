import 'package:dio/dio.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';

import 'eddy_scout_http_response.dart';

/// Shared HTTP client for public conditions APIs (NWS, NOAA, USGS, Open-Meteo).
///
/// Backed by [Dio] from [EddyScoutDioFactory] with retry and optional debug logging.
class EddyScoutHttpClient {
  EddyScoutHttpClient({
    Dio? dio,
    this.requestTimeout = const Duration(seconds: 18),
    bool enableDebugLogging = false,
  }) : _dio =
           dio ??
           EddyScoutDioFactory(enableDebugLogging: enableDebugLogging).create();

  static const userAgent = EddyScoutDioFactory.defaultUserAgent;

  final Dio _dio;
  final Duration requestTimeout;

  Future<EddyScoutHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await _dio.get<String>(
      uri.toString(),
      options: Options(
        headers: headers,
        receiveTimeout: requestTimeout,
        responseType: ResponseType.plain,
      ),
    );
    return EddyScoutHttpResponse(
      statusCode: response.statusCode ?? 0,
      body: response.data ?? '',
    );
  }

  /// NWS prefers `application/geo+json` for api.weather.gov.
  Future<EddyScoutHttpResponse> getNws(Uri uri) {
    return get(uri, headers: {'Accept': 'application/geo+json'});
  }

  Future<Map<String, dynamic>?> getJson(Uri uri) async {
    try {
      final response = await _dio.get<dynamic>(
        uri.toString(),
        options: Options(
          receiveTimeout: requestTimeout,
          responseType: ResponseType.json,
        ),
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

  Future<Map<String, dynamic>?> getNwsJson(Uri uri) async {
    try {
      final response = await _dio.get<dynamic>(
        uri.toString(),
        options: Options(
          headers: {'Accept': 'application/geo+json'},
          receiveTimeout: requestTimeout,
          responseType: ResponseType.json,
        ),
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

  void close() {
    _dio.close(force: true);
  }
}
