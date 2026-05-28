import 'package:eddyscout_conditions/src/domain/repositories/condition_reports_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable [ConditionReportsRepository] token for presentation and data.
///
/// Bound at the app composition root. Tests override with a mock or fake.
final Provider<ConditionReportsRepository> conditionReportsRepositoryProvider =
    Provider<ConditionReportsRepository>(
      (ref) => throw UnimplementedError(
        'Override conditionReportsRepositoryProvider in ProviderScope '
        '(see apps/eddyscout/lib/main.dart).',
      ),
    );
