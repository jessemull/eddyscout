// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_search_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bundled launch search repository for the map overlay.

@ProviderFor(mapSearchRepository)
final mapSearchRepositoryProvider = MapSearchRepositoryProvider._();

/// Bundled launch search repository for the map overlay.

final class MapSearchRepositoryProvider
    extends
        $FunctionalProvider<
          MapSearchRepository,
          MapSearchRepository,
          MapSearchRepository
        >
    with $Provider<MapSearchRepository> {
  /// Bundled launch search repository for the map overlay.
  MapSearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchRepositoryHash();

  @$internal
  @override
  $ProviderElement<MapSearchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MapSearchRepository create(Ref ref) {
    return mapSearchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapSearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapSearchRepository>(value),
    );
  }
}

String _$mapSearchRepositoryHash() =>
    r'4d2fffc03bd51d01dd2baad29c0b4acb3fa29434';
