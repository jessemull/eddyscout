import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/conditions_http_provider.dart';
import 'package:eddyscout_conditions/src/data/conditions_service.dart';
import 'package:eddyscout_conditions/src/domain/conditions_load_exception.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conditions_provider.g.dart';

Duration? _disableProviderRetry(int retryCount, Object error) => null;

/// Shared conditions repository (HTTP-backed [ConditionsService]).
@riverpod
ConditionsService conditionsService(Ref ref) {
  return ConditionsService(ref.watch(conditionsHttpClientProvider));
}

/// Shared conditions repository (HTTP-backed [ConditionsService]).
@riverpod
ConditionsRepository conditionsRepository(Ref ref) {
  return ref.watch(conditionsServiceProvider);
}

/// Loads environmental conditions for a launch.
@Riverpod(retry: _disableProviderRetry)
Future<ConditionsSnapshot> conditionsSnapshot(
  Ref ref,
  LaunchPoint launch,
) async {
  final cancelToken = CancelToken();
  ref.onDispose(() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('conditionsSnapshotProvider disposed');
    }
  });
  final result = await ref
      .watch(conditionsRepositoryProvider)
      .load(launch, cancelToken: cancelToken);
  return result.when(
    success: (value) => value,
    failure: (error) => throw ConditionsLoadException(error),
  );
}
