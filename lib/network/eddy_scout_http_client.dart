import 'dart:convert';

import 'package:http/http.dart' as http;

/// Shared HTTP client: NWS requires a descriptive User-Agent.
class EddyScoutHttpClient {
  EddyScoutHttpClient({
    http.Client? inner,
    this.timeout = const Duration(seconds: 18),
  }) : _inner = inner ?? http.Client();

  static const userAgent = 'EddyScout/1.0 (eddyscout; conditions)';

  final http.Client _inner;
  final Duration timeout;

  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) {
    final merged = <String, String>{
      'User-Agent': userAgent,
      'Accept': 'application/json',
      ...?headers,
    };
    return _inner.get(uri, headers: merged).timeout(timeout);
  }

  /// NWS prefers `application/geo+json` for api.weather.gov.
  Future<http.Response> getNws(Uri uri) {
    return get(uri, headers: {'Accept': 'application/geo+json'});
  }

  Future<Map<String, dynamic>?> getJson(Uri uri) async {
    final res = await get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<Map<String, dynamic>?> getNwsJson(Uri uri) async {
    final res = await getNws(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  void close() => _inner.close();
}
