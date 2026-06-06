// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_reports_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [ConditionReportsRepository] token for presentation and data.
///
/// Bound at the app composition root. Tests override with a mock or fake.

@ProviderFor(conditionReportsRepository)
final conditionReportsRepositoryProvider =
    ConditionReportsRepositoryProvider._();

/// Injectable [ConditionReportsRepository] token for presentation and data.
///
/// Bound at the app composition root. Tests override with a mock or fake.

final class ConditionReportsRepositoryProvider
    extends
        $FunctionalProvider<
          ConditionReportsRepository,
          ConditionReportsRepository,
          ConditionReportsRepository
        >
    with $Provider<ConditionReportsRepository> {
  /// Injectable [ConditionReportsRepository] token for presentation and data.
  ///
  /// Bound at the app composition root. Tests override with a mock or fake.
  ConditionReportsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionReportsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionReportsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConditionReportsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionReportsRepository create(Ref ref) {
    return conditionReportsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionReportsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionReportsRepository>(value),
    );
  }
}

String _$conditionReportsRepositoryHash() =>
    r'fc876e33a003e16706d863213ed3a41619f55132';
