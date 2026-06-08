import 'package:eddyscout_conditions/src/domain/repositories/conditions_ai_summary_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conditions_ai_summary_repository_provider.g.dart';

/// Injectable [ConditionsAiSummaryRepository] token for presentation and tests.
@Riverpod(keepAlive: true)
ConditionsAiSummaryRepository conditionsAiSummaryRepository(Ref ref) {
  throw UnimplementedError(
    'Override conditionsAiSummaryRepositoryProvider in ProviderScope.',
  );
}
