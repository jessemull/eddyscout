import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/src/user_preferences_key_value_store_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'display_unit_system_provider.g.dart';

/// User preference for metric vs imperial distance and speed display.
@Riverpod(keepAlive: true)
class UnitSystem extends _$UnitSystem {
  @override
  Future<DisplayUnitSystem> build() async {
    final store = await ref.watch(userPreferencesKeyValueStoreProvider.future);
    final raw = await store.getString(kDisplayUnitSystemKey);
    return parseDisplayUnitSystem(raw) ?? kDefaultDisplayUnitSystem;
  }

  /// Persists [system] and updates provider state.
  Future<void> setSystem(DisplayUnitSystem system) async {
    final store = await ref.read(userPreferencesKeyValueStoreProvider.future);
    await store.setString(
      kDisplayUnitSystemKey,
      displayUnitSystemToStored(system),
    );
    state = AsyncData(system);
  }
}

/// Current display unit system, falling back to [kDefaultDisplayUnitSystem].
@Riverpod(keepAlive: true)
DisplayUnitSystem effectiveDisplayUnitSystem(Ref ref) {
  final asyncSystem = ref.watch(unitSystemProvider);
  return asyncSystem.whenOrNull(data: (value) => value) ??
      kDefaultDisplayUnitSystem;
}
