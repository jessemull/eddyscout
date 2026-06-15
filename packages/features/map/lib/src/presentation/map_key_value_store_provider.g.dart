// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_key_value_store_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide key-value store for map user preferences.
///
/// Override at the composition root with the shared [KeyValueStore] instance.

@ProviderFor(mapKeyValueStore)
final mapKeyValueStoreProvider = MapKeyValueStoreProvider._();

/// App-wide key-value store for map user preferences.
///
/// Override at the composition root with the shared [KeyValueStore] instance.

final class MapKeyValueStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<KeyValueStore>,
          KeyValueStore,
          FutureOr<KeyValueStore>
        >
    with $FutureModifier<KeyValueStore>, $FutureProvider<KeyValueStore> {
  /// App-wide key-value store for map user preferences.
  ///
  /// Override at the composition root with the shared [KeyValueStore] instance.
  MapKeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapKeyValueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapKeyValueStoreHash();

  @$internal
  @override
  $FutureProviderElement<KeyValueStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KeyValueStore> create(Ref ref) {
    return mapKeyValueStore(ref);
  }
}

String _$mapKeyValueStoreHash() => r'98fcb8dd69a696e08032b8fa243d36bdac466b4e';
