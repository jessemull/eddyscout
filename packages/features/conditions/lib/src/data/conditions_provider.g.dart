// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared conditions repository (HTTP-backed [ConditionsService]).

@ProviderFor(conditionsService)
final conditionsServiceProvider = ConditionsServiceProvider._();

/// Shared conditions repository (HTTP-backed [ConditionsService]).

final class ConditionsServiceProvider
    extends
        $FunctionalProvider<
          ConditionsService,
          ConditionsService,
          ConditionsService
        >
    with $Provider<ConditionsService> {
  /// Shared conditions repository (HTTP-backed [ConditionsService]).
  ConditionsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionsServiceHash();

  @$internal
  @override
  $ProviderElement<ConditionsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionsService create(Ref ref) {
    return conditionsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionsService>(value),
    );
  }
}

String _$conditionsServiceHash() => r'd88bbca12c0b0616caa207229046938369b7423a';

/// Shared conditions repository (HTTP-backed [ConditionsService]).

@ProviderFor(conditionsRepository)
final conditionsRepositoryProvider = ConditionsRepositoryProvider._();

/// Shared conditions repository (HTTP-backed [ConditionsService]).

final class ConditionsRepositoryProvider
    extends
        $FunctionalProvider<
          ConditionsRepository,
          ConditionsRepository,
          ConditionsRepository
        >
    with $Provider<ConditionsRepository> {
  /// Shared conditions repository (HTTP-backed [ConditionsService]).
  ConditionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConditionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionsRepository create(Ref ref) {
    return conditionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionsRepository>(value),
    );
  }
}

String _$conditionsRepositoryHash() =>
    r'8e5f0d33860eea976dc45554adc06fa01126d4a8';

/// Loads environmental conditions for a launch.

@ProviderFor(conditionsSnapshot)
final conditionsSnapshotProvider = ConditionsSnapshotFamily._();

/// Loads environmental conditions for a launch.

final class ConditionsSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConditionsSnapshot>,
          ConditionsSnapshot,
          FutureOr<ConditionsSnapshot>
        >
    with
        $FutureModifier<ConditionsSnapshot>,
        $FutureProvider<ConditionsSnapshot> {
  /// Loads environmental conditions for a launch.
  ConditionsSnapshotProvider._({
    required ConditionsSnapshotFamily super.from,
    required LaunchPoint super.argument,
  }) : super(
         retry: _disableProviderRetry,
         name: r'conditionsSnapshotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conditionsSnapshotHash();

  @override
  String toString() {
    return r'conditionsSnapshotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ConditionsSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConditionsSnapshot> create(Ref ref) {
    final argument = this.argument as LaunchPoint;
    return conditionsSnapshot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConditionsSnapshotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conditionsSnapshotHash() =>
    r'b40f4f8863ef1a9edd1cdbd6280aeccec123fc9c';

/// Loads environmental conditions for a launch.

final class ConditionsSnapshotFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ConditionsSnapshot>, LaunchPoint> {
  ConditionsSnapshotFamily._()
    : super(
        retry: _disableProviderRetry,
        name: r'conditionsSnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads environmental conditions for a launch.

  ConditionsSnapshotProvider call(LaunchPoint launch) =>
      ConditionsSnapshotProvider._(argument: launch, from: this);

  @override
  String toString() => r'conditionsSnapshotProvider';
}
