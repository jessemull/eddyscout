import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'key_value_store_provider.g.dart';

/// App-wide `KeyValueStore` backed by `SharedPreferences`.
///
/// Kept alive for the app lifetime so preference reads are not repeated.
@Riverpod(keepAlive: true)
Future<KeyValueStore> keyValueStore(Ref ref) =>
    SharedPreferencesKeyValueStore.open();
