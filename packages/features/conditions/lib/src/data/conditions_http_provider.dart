import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conditions_http_provider.g.dart';

/// Shared conditions HTTP client (Dio-backed).
@riverpod
EddyScoutHttpClient conditionsHttpClient(Ref ref) {
  final client = EddyScoutHttpClient(enableDebugLogging: kDebugMode);
  ref.onDispose(client.close);
  return client;
}
