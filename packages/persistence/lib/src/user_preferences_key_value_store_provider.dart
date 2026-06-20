import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_preferences_key_value_store_provider.g.dart';

/// App-wide key-value store for cross-feature user preferences.
///
/// Override at the composition root with the shared [KeyValueStore] instance.
@Riverpod(keepAlive: true)
Future<KeyValueStore> userPreferencesKeyValueStore(Ref ref) async {
  throw UnimplementedError(
    'Override userPreferencesKeyValueStoreProvider in ProviderScope '
    '(see apps/eddyscout/lib/bootstrap/app_provider_overrides.dart).',
  );
}
