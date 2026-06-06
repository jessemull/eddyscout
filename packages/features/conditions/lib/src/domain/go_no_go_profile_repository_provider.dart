import 'package:eddyscout_conditions/src/domain/repositories/go_no_go_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_no_go_profile_repository_provider.g.dart';

/// Injectable [GoNoGoProfileRepository] token for presentation and data.
///
/// Bound at the app composition root. Tests override with a mock or fake.
@Riverpod(keepAlive: true)
GoNoGoProfileRepository goNoGoProfileRepository(Ref ref) {
  throw UnimplementedError(
    'Override goNoGoProfileRepositoryProvider in ProviderScope '
    '(see apps/eddyscout/lib/main.dart).',
  );
}
