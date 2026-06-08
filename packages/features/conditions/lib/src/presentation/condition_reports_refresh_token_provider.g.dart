// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_reports_refresh_token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Incremented after a paddler submits a condition report to refresh the list.

@ProviderFor(ConditionReportsRefreshToken)
final conditionReportsRefreshTokenProvider =
    ConditionReportsRefreshTokenProvider._();

/// Incremented after a paddler submits a condition report to refresh the list.
final class ConditionReportsRefreshTokenProvider
    extends $NotifierProvider<ConditionReportsRefreshToken, int> {
  /// Incremented after a paddler submits a condition report to refresh the list.
  ConditionReportsRefreshTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionReportsRefreshTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionReportsRefreshTokenHash();

  @$internal
  @override
  ConditionReportsRefreshToken create() => ConditionReportsRefreshToken();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$conditionReportsRefreshTokenHash() =>
    r'6b0eba2f07f13d57a5db774953db7d04601c48c6';

/// Incremented after a paddler submits a condition report to refresh the list.

abstract class _$ConditionReportsRefreshToken extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
