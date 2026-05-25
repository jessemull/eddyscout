import 'package:eddyscout/preferences/go_no_go_profile_repository.dart';
import 'package:eddyscout/preferences/shared_preferences_provider.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
