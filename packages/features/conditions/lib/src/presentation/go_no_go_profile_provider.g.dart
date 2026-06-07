// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_no_go_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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
    r'efd5ee01031bad8f8fdeb97d96e55dd458df6e1f';

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
