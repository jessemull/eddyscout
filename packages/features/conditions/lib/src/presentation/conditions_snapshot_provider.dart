import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/conditions_repository_provider.dart';
import 'package:eddyscout_conditions/src/presentation/provider_result.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conditions_snapshot_provider.g.dart';

/// Loads environmental conditions for a launch.
@Riverpod(retry: disableProviderRetry)
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
  return unwrapResultForAsyncProvider(result);
}
