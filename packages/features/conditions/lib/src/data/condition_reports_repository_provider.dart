import 'package:eddyscout_conditions/src/data/repositories/condition_reports_repository_impl.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_reports_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable [ConditionReportsRepository] for tests and overrides.
final Provider<ConditionReportsRepository> conditionReportsRepositoryProvider =
    Provider<ConditionReportsRepository>(
      (ref) => const ConditionReportsRepositoryImpl(),
    );
