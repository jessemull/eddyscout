import 'package:eddyscout_conditions/src/domain/repositories/condition_report_moderation_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'condition_report_moderation_repository_provider.g.dart';

/// Injectable [ConditionReportModerationRepository] token.
@Riverpod(keepAlive: true)
ConditionReportModerationRepository conditionReportModerationRepository(
  Ref ref,
) {
  throw UnimplementedError(
    'Override conditionReportModerationRepositoryProvider in ProviderScope.',
  );
}
