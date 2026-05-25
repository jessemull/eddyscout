import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../decision/go_no_go.dart';
import 'go_no_go_profile_repository.dart';
import 'shared_preferences_provider.dart';

final goNoGoProfileRepositoryProvider = Provider<GoNoGoProfileRepository>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return GoNoGoProfileRepository(prefs);
});

/// User skill profile for go/no-go wind thresholds.
final goNoGoProfileProvider =
    AsyncNotifierProvider<GoNoGoProfileNotifier, GoNoGoProfile>(
      GoNoGoProfileNotifier.new,
    );

class GoNoGoProfileNotifier extends AsyncNotifier<GoNoGoProfile> {
  @override
  Future<GoNoGoProfile> build() async {
    await ref.watch(sharedPreferencesProvider.future);
    return ref.read(goNoGoProfileRepositoryProvider).read();
  }

  Future<void> setProfile(GoNoGoProfile profile) async {
    state = AsyncData(profile);
    await ref.read(goNoGoProfileRepositoryProvider).write(profile);
  }
}
