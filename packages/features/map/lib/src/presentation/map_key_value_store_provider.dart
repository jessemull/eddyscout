import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_key_value_store_provider.g.dart';

/// App-wide key-value store for map user preferences.
///
/// Override at the composition root with the shared [KeyValueStore] instance.
@Riverpod(keepAlive: true)
Future<KeyValueStore> mapKeyValueStore(Ref ref) async {
  throw UnimplementedError(
    'Override mapKeyValueStoreProvider in ProviderScope '
    '(see apps/eddyscout/lib/bootstrap/app_provider_overrides.dart).',
  );
}
