import 'package:eddyscout_conditions/src/data/conditions_http_provider.dart';
import 'package:eddyscout_conditions/src/data/conditions_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conditions_service_provider.g.dart';

/// HTTP-backed conditions service for repository wiring at the app root.
@riverpod
ConditionsService conditionsService(Ref ref) {
  return ConditionsService(ref.watch(conditionsHttpClientProvider));
}
