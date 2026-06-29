import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/debug/conditions_debug_log.dart';
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
  conditionsDebugLogLaunch('snapshot START', launch);
  conditionsDebugLogTs('snapshot START ${launch.id}');

  final cancelToken = CancelToken();
  ref.onDispose(() {
    conditionsDebugLog(
      'snapshot DISPOSE ${launch.id} '
      'cancel=${!cancelToken.isCancelled}',
    );
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('conditionsSnapshotProvider disposed');
    }
  });
  try {
    final result = await ref
        .watch(conditionsRepositoryProvider)
        .load(launch, cancelToken: cancelToken);
    final snapshot = unwrapResultForAsyncProvider(result);
    conditionsDebugLogSnapshot('snapshot OK', launch, snapshot);
    return snapshot;
  } on Object catch (error, stackTrace) {
    conditionsDebugLog(
      'snapshot FAIL ${launch.id} error=$error\n$stackTrace',
    );
    rethrow;
  }
}
