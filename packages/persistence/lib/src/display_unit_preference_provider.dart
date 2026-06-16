import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/src/user_preferences_key_value_store_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'display_unit_preference_provider.g.dart';

/// User preference for metric vs imperial distance and speed display.
@Riverpod(keepAlive: true)
class DisplayUnitPreference extends _$DisplayUnitPreference {
  @override
  Future<DisplayUnitSystem> build() async {
    final store = await ref.watch(userPreferencesKeyValueStoreProvider.future);
    final stored = await store.getString(kDisplayUnitSystemKey);
    return parseDisplayUnitSystem(stored);
  }

  /// Persists [units] and updates provider state.
  Future<void> setUnits(DisplayUnitSystem units) async {
    final store = await ref.read(userPreferencesKeyValueStoreProvider.future);
    await store.setString(
      kDisplayUnitSystemKey,
      encodeDisplayUnitSystem(units),
    );
    state = AsyncData(units);
  }
}

/// Current display units, falling back to metric while loading or on error.
@Riverpod(keepAlive: true)
DisplayUnitSystem effectiveDisplayUnits(Ref ref) {
  final asyncUnits = ref.watch(displayUnitPreferenceProvider);
  return asyncUnits.whenOrNull(data: (value) => value) ??
      DisplayUnitSystem.metric;
}
