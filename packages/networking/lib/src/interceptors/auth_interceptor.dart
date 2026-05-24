import 'package:dio/dio.dart';

/// Adds authorization headers to outgoing requests.
///
/// Implementations must handle token refresh when receiving 401 responses.
abstract class AuthInterceptor extends Interceptor {
  /// Retrieves the current access token.
  Future<String?> getAccessToken();

  /// Refreshes an expired token. Return the new token or null on failure.
  Future<String?> refreshToken();
}
