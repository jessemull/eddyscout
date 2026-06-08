import 'package:eddyscout_conditions/src/domain/repositories/conditions_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conditions_repository_provider.g.dart';

/// Injectable [ConditionsRepository] token for presentation and tests.
@Riverpod(keepAlive: true)
ConditionsRepository conditionsRepository(Ref ref) {
  throw UnimplementedError(
    'Override conditionsRepositoryProvider in ProviderScope '
    '(see apps/eddyscout/lib/bootstrap/app_provider_overrides.dart).',
  );
}
