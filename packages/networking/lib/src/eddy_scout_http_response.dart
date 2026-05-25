/// Minimal HTTP response surface for conditions fetchers (Dio-backed).
class EddyScoutHttpResponse {
  /// Creates a response with [statusCode] and response [body].
  const EddyScoutHttpResponse({required this.statusCode, required this.body});

  /// HTTP status code from the upstream service.
  final int statusCode;

  /// Raw response body (plain text or JSON string).
  final String body;
}
