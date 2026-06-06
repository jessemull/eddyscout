import 'package:eddyscout_conditions/src/domain/repositories/condition_reports_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'condition_reports_repository_provider.g.dart';

/// Injectable [ConditionReportsRepository] token for presentation and data.
///
/// Bound at the app composition root. Tests override with a mock or fake.
@Riverpod(keepAlive: true)
ConditionReportsRepository conditionReportsRepository(Ref ref) {
  throw UnimplementedError(
    'Override conditionReportsRepositoryProvider in ProviderScope '
    '(see apps/eddyscout/lib/main.dart).',
  );
}
