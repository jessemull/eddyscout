/// Minimal HTTP response surface for conditions fetchers (Dio-backed).
class EddyScoutHttpResponse {
  const EddyScoutHttpResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}
