import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goNoGoProfileRepositoryProvider = Provider<GoNoGoProfileRepository>((
  ref,
) {
  final store = ref.watch(keyValueStoreProvider).requireValue;
  return GoNoGoProfileRepositoryImpl(store);
});

/// User skill profile for go/no-go wind thresholds.
final goNoGoProfileProvider =
    AsyncNotifierProvider<GoNoGoProfileNotifier, GoNoGoProfile>(
      GoNoGoProfileNotifier.new,
      retry: (_, _) => null,
    );

class GoNoGoProfileNotifier extends AsyncNotifier<GoNoGoProfile> {
  @override
  Future<GoNoGoProfile> build() async {
    await ref.watch(keyValueStoreProvider.future);
    final result = await ref.read(goNoGoProfileRepositoryProvider).read();
    return result.when(
      success: (value) => value,
      failure: (error) => throw Exception(error.message),
    );
  }

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
