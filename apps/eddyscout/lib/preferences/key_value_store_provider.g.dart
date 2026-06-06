// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_value_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide `KeyValueStore` backed by `SharedPreferences`.
///
/// Kept alive for the app lifetime so preference reads are not repeated.

@ProviderFor(keyValueStore)
final keyValueStoreProvider = KeyValueStoreProvider._();

/// App-wide `KeyValueStore` backed by `SharedPreferences`.
///
/// Kept alive for the app lifetime so preference reads are not repeated.

final class KeyValueStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<KeyValueStore>,
          KeyValueStore,
          FutureOr<KeyValueStore>
        >
    with $FutureModifier<KeyValueStore>, $FutureProvider<KeyValueStore> {
  /// App-wide `KeyValueStore` backed by `SharedPreferences`.
  ///
  /// Kept alive for the app lifetime so preference reads are not repeated.
  KeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyValueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyValueStoreHash();

  @$internal
  @override
  $FutureProviderElement<KeyValueStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KeyValueStore> create(Ref ref) {
    return keyValueStore(ref);
  }
}

String _$keyValueStoreHash() => r'022e1aea08e91451cb31c5cfb0a7cc8ca0669f7e';
