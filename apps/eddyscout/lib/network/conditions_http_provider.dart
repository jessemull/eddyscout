import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'eddy_scout_http_client.dart';

/// Shared conditions HTTP client (Dio-backed).
final conditionsHttpClientProvider = Provider<EddyScoutHttpClient>((ref) {
  final client = EddyScoutHttpClient(enableDebugLogging: kDebugMode);
  ref.onDispose(client.close);
  return client;
});
