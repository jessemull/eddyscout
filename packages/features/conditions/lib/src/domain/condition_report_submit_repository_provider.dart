import 'package:eddyscout_conditions/src/domain/repositories/condition_report_submit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'condition_report_submit_repository_provider.g.dart';

/// Injectable submit repository token for presentation and tests.
@Riverpod(keepAlive: true)
ConditionReportSubmitRepository conditionReportSubmitRepository(Ref ref) {
  throw UnimplementedError(
    'Override conditionReportSubmitRepositoryProvider in ProviderScope.',
  );
}
