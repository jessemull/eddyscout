import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide `KeyValueStore` backed by `SharedPreferences`.
///
/// Kept alive for the app lifetime so preference reads are not repeated.
final keyValueStoreProvider = FutureProvider<KeyValueStore>((ref) async {
  ref.keepAlive();
  return SharedPreferencesKeyValueStore.open();
});
