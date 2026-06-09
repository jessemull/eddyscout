// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_routes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves launch ids for saved route UI; overridden in the app shell.

@ProviderFor(launchPointLookup)
final launchPointLookupProvider = LaunchPointLookupProvider._();

/// Resolves launch ids for saved route UI; overridden in the app shell.

final class LaunchPointLookupProvider
    extends
        $FunctionalProvider<
          LaunchPointLookup,
          LaunchPointLookup,
          LaunchPointLookup
        >
    with $Provider<LaunchPointLookup> {
  /// Resolves launch ids for saved route UI; overridden in the app shell.
  LaunchPointLookupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchPointLookupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchPointLookupHash();

  @$internal
  @override
  $ProviderElement<LaunchPointLookup> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LaunchPointLookup create(Ref ref) {
    return launchPointLookup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchPointLookup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchPointLookup>(value),
    );
  }
}

String _$launchPointLookupHash() => r'6c3d52f039df3280fad3611c3257c891f30197a2';

/// All saved routes from local storage.

@ProviderFor(SavedRoutesList)
final savedRoutesListProvider = SavedRoutesListProvider._();

/// All saved routes from local storage.
final class SavedRoutesListProvider
    extends $AsyncNotifierProvider<SavedRoutesList, List<SavedRoute>> {
  /// All saved routes from local storage.
  SavedRoutesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRoutesListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRoutesListHash();

  @$internal
  @override
  SavedRoutesList create() => SavedRoutesList();
}

String _$savedRoutesListHash() => r'd71b1f3bc4ebc1306044532150520b1dc4ef1fbb';

/// All saved routes from local storage.

abstract class _$SavedRoutesList extends $AsyncNotifier<List<SavedRoute>> {
  FutureOr<List<SavedRoute>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SavedRoute>>, List<SavedRoute>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SavedRoute>>, List<SavedRoute>>,
              AsyncValue<List<SavedRoute>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Favorite saved routes only.

@ProviderFor(savedRoutesFavorites)
final savedRoutesFavoritesProvider = SavedRoutesFavoritesProvider._();

/// Favorite saved routes only.

final class SavedRoutesFavoritesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedRoute>>,
          List<SavedRoute>,
          FutureOr<List<SavedRoute>>
        >
    with $FutureModifier<List<SavedRoute>>, $FutureProvider<List<SavedRoute>> {
  /// Favorite saved routes only.
  SavedRoutesFavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRoutesFavoritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRoutesFavoritesHash();

  @$internal
  @override
  $FutureProviderElement<List<SavedRoute>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SavedRoute>> create(Ref ref) {
    return savedRoutesFavorites(ref);
  }
}

String _$savedRoutesFavoritesHash() =>
    r'92af2914167c501adf030a0cbd4b5f69799adee5';

/// Single saved route by id.

@ProviderFor(savedRouteById)
final savedRouteByIdProvider = SavedRouteByIdFamily._();

/// Single saved route by id.

final class SavedRouteByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavedRoute?>,
          SavedRoute?,
          FutureOr<SavedRoute?>
        >
    with $FutureModifier<SavedRoute?>, $FutureProvider<SavedRoute?> {
  /// Single saved route by id.
  SavedRouteByIdProvider._({
    required SavedRouteByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savedRouteByIdProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savedRouteByIdHash();

  @override
  String toString() {
    return r'savedRouteByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SavedRoute?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SavedRoute?> create(Ref ref) {
    final argument = this.argument as String;
    return savedRouteById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SavedRouteByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savedRouteByIdHash() => r'8e9b4cbdee3e89f654435e75241a3e44a86ff6f8';

/// Single saved route by id.

final class SavedRouteByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SavedRoute?>, String> {
  SavedRouteByIdFamily._()
    : super(
        retry: null,
        name: r'savedRouteByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Single saved route by id.

  SavedRouteByIdProvider call(String id) =>
      SavedRouteByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'savedRouteByIdProvider';
}

/// Write operations for saved routes.

@ProviderFor(SavedRoutesController)
final savedRoutesControllerProvider = SavedRoutesControllerProvider._();

/// Write operations for saved routes.
final class SavedRoutesControllerProvider
    extends $NotifierProvider<SavedRoutesController, void> {
  /// Write operations for saved routes.
  SavedRoutesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRoutesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRoutesControllerHash();

  @$internal
  @override
  SavedRoutesController create() => SavedRoutesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$savedRoutesControllerHash() =>
    r'97924eb3a12647d7c24312bb21409802e147598f';

/// Write operations for saved routes.

abstract class _$SavedRoutesController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Draft saved route to load on the map tab on next visit.

@ProviderFor(PendingSavedRouteLoad)
final pendingSavedRouteLoadProvider = PendingSavedRouteLoadProvider._();

/// Draft saved route to load on the map tab on next visit.
final class PendingSavedRouteLoadProvider
    extends $NotifierProvider<PendingSavedRouteLoad, SavedRoute?> {
  /// Draft saved route to load on the map tab on next visit.
  PendingSavedRouteLoadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSavedRouteLoadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSavedRouteLoadHash();

  @$internal
  @override
  PendingSavedRouteLoad create() => PendingSavedRouteLoad();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedRoute? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedRoute?>(value),
    );
  }
}

String _$pendingSavedRouteLoadHash() =>
    r'25478f8fc3483bda6f6ef32eaaa98e9d728b05ed';

/// Draft saved route to load on the map tab on next visit.

abstract class _$PendingSavedRouteLoad extends $Notifier<SavedRoute?> {
  SavedRoute? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SavedRoute?, SavedRoute?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SavedRoute?, SavedRoute?>,
              SavedRoute?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
