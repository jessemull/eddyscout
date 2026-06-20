// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_key_value_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide key-value store for cross-feature user preferences.
///
/// Override at the composition root with the shared [KeyValueStore] instance.

@ProviderFor(userPreferencesKeyValueStore)
final userPreferencesKeyValueStoreProvider =
    UserPreferencesKeyValueStoreProvider._();

/// App-wide key-value store for cross-feature user preferences.
///
/// Override at the composition root with the shared [KeyValueStore] instance.

final class UserPreferencesKeyValueStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<KeyValueStore>,
          KeyValueStore,
          FutureOr<KeyValueStore>
        >
    with $FutureModifier<KeyValueStore>, $FutureProvider<KeyValueStore> {
  /// App-wide key-value store for cross-feature user preferences.
  ///
  /// Override at the composition root with the shared [KeyValueStore] instance.
  UserPreferencesKeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesKeyValueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesKeyValueStoreHash();

  @$internal
  @override
  $FutureProviderElement<KeyValueStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KeyValueStore> create(Ref ref) {
    return userPreferencesKeyValueStore(ref);
  }
}

String _$userPreferencesKeyValueStoreHash() =>
    r'5ca0acfef877311dc22318e3b9132309c6f5d6b8';
