// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_no_go_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goNoGoProfileRepository)
final goNoGoProfileRepositoryProvider = GoNoGoProfileRepositoryProvider._();

final class GoNoGoProfileRepositoryProvider
    extends
        $FunctionalProvider<
          GoNoGoProfileRepository,
          GoNoGoProfileRepository,
          GoNoGoProfileRepository
        >
    with $Provider<GoNoGoProfileRepository> {
  GoNoGoProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goNoGoProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goNoGoProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoNoGoProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoNoGoProfileRepository create(Ref ref) {
    return goNoGoProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoNoGoProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoNoGoProfileRepository>(value),
    );
  }
}

String _$goNoGoProfileRepositoryHash() =>
    r'f098e5eff5d58677d419f8bf4b36d95867b105d9';

/// User skill profile for go/no-go wind thresholds.

@ProviderFor(GoNoGoProfileNotifier)
final goNoGoProfileProvider = GoNoGoProfileNotifierProvider._();

/// User skill profile for go/no-go wind thresholds.
final class GoNoGoProfileNotifierProvider
    extends $AsyncNotifierProvider<GoNoGoProfileNotifier, GoNoGoProfile> {
  /// User skill profile for go/no-go wind thresholds.
  GoNoGoProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: _goNoGoProfileRetry,
        name: r'goNoGoProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goNoGoProfileNotifierHash();

  @$internal
  @override
  GoNoGoProfileNotifier create() => GoNoGoProfileNotifier();
}

String _$goNoGoProfileNotifierHash() =>
    r'33d42482163a40d7b0d46f871f99ae3b58a61fab';

/// User skill profile for go/no-go wind thresholds.

abstract class _$GoNoGoProfileNotifier extends $AsyncNotifier<GoNoGoProfile> {
  FutureOr<GoNoGoProfile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GoNoGoProfile>, GoNoGoProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GoNoGoProfile>, GoNoGoProfile>,
              AsyncValue<GoNoGoProfile>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
