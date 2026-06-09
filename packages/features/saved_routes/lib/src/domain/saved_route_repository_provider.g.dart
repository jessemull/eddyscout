// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_route_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [SavedRouteRepository] token for presentation and tests.

@ProviderFor(savedRouteRepository)
final savedRouteRepositoryProvider = SavedRouteRepositoryProvider._();

/// Injectable [SavedRouteRepository] token for presentation and tests.

final class SavedRouteRepositoryProvider
    extends
        $FunctionalProvider<
          SavedRouteRepository,
          SavedRouteRepository,
          SavedRouteRepository
        >
    with $Provider<SavedRouteRepository> {
  /// Injectable [SavedRouteRepository] token for presentation and tests.
  SavedRouteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRouteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRouteRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedRouteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedRouteRepository create(Ref ref) {
    return savedRouteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedRouteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedRouteRepository>(value),
    );
  }
}

String _$savedRouteRepositoryHash() =>
    r'bea32981a416d0f114162bfd4e774afa73c6eba7';
