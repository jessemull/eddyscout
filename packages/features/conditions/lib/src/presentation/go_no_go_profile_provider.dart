import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go_profile_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_no_go_profile_provider.g.dart';

Duration? _goNoGoProfileRetry(int retryCount, Object error) => null;

/// User skill profile for go/no-go wind thresholds.
@Riverpod(
  name: 'goNoGoProfileProvider',
  keepAlive: true,
  retry: _goNoGoProfileRetry,
)
class GoNoGoProfileNotifier extends _$GoNoGoProfileNotifier {
  @override
  Future<GoNoGoProfile> build() async {
    final result = await ref.read(goNoGoProfileRepositoryProvider).read();
    return result.when(
      success: (value) => value,
      failure: (error) => throw Exception(error.message),
    );
  }

  /// Persists [profile] and updates the in-memory skill selection.
  Future<void> setProfile(GoNoGoProfile profile) async {
    state = AsyncData(profile);
    final result = await ref
        .read(goNoGoProfileRepositoryProvider)
        .write(profile);
    result.when(
      success: (_) {},
      failure: (error) {
        state = AsyncError(error, error.stackTrace ?? StackTrace.current);
      },
    );
  }
}
