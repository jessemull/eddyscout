// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_routes_database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide saved routes Drift database.
///
/// Override in tests with [openSavedRoutesDatabaseForTest].

@ProviderFor(savedRoutesDatabase)
final savedRoutesDatabaseProvider = SavedRoutesDatabaseProvider._();

/// App-wide saved routes Drift database.
///
/// Override in tests with [openSavedRoutesDatabaseForTest].

final class SavedRoutesDatabaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavedRoutesDatabase>,
          SavedRoutesDatabase,
          FutureOr<SavedRoutesDatabase>
        >
    with
        $FutureModifier<SavedRoutesDatabase>,
        $FutureProvider<SavedRoutesDatabase> {
  /// App-wide saved routes Drift database.
  ///
  /// Override in tests with [openSavedRoutesDatabaseForTest].
  SavedRoutesDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRoutesDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRoutesDatabaseHash();

  @$internal
  @override
  $FutureProviderElement<SavedRoutesDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SavedRoutesDatabase> create(Ref ref) {
    return savedRoutesDatabase(ref);
  }
}

String _$savedRoutesDatabaseHash() =>
    r'ad64e23fcd29a9eab0b4a6296f402fd0829ee977';
