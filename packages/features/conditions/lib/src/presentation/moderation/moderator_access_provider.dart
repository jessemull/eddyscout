import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_moderation_repository_provider.dart';
import 'package:eddyscout_conditions/src/presentation/provider_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'moderator_access_provider.g.dart';

/// Whether the signed-in user can open the moderation queue.
@Riverpod(keepAlive: true)
Future<bool> moderatorAccess(Ref ref) async {
  final cancelToken = CancelToken();
  ref.onDispose(() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('moderatorAccessProvider disposed');
    }
  });
  final result = await ref
      .read(conditionReportModerationRepositoryProvider)
      .checkModeratorAccess(cancelToken: cancelToken);
  return unwrapResultForAsyncProvider(result);
}
