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
    r'55a1e92efe93693a9a5d22a2d50603b06ef2364c';

/// User skill profile for go/no-go wind thresholds.

abstract class _$GoNoGoProfileNotifier extends $AsyncNotifier<GoNoGoProfile> {
  FutureOr<GoNoGoProfile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GoNoGoProfile>, GoNoGoProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GoNoGoProfile>, GoNoGoProfile>,
              AsyncValue<GoNoGoProfile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
