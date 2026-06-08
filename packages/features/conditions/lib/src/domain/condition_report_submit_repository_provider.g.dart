// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_report_submit_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [ConditionReportSubmitRepository] token for presentation and tests.

@ProviderFor(conditionReportSubmitRepository)
final conditionReportSubmitRepositoryProvider =
    ConditionReportSubmitRepositoryProvider._();

/// Injectable [ConditionReportSubmitRepository] token for presentation and tests.

final class ConditionReportSubmitRepositoryProvider
    extends
        $FunctionalProvider<
          ConditionReportSubmitRepository,
          ConditionReportSubmitRepository,
          ConditionReportSubmitRepository
        >
    with $Provider<ConditionReportSubmitRepository> {
  /// Injectable [ConditionReportSubmitRepository] token for presentation and tests.
  ConditionReportSubmitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionReportSubmitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionReportSubmitRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConditionReportSubmitRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionReportSubmitRepository create(Ref ref) {
    return conditionReportSubmitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionReportSubmitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionReportSubmitRepository>(
        value,
      ),
    );
  }
}

String _$conditionReportSubmitRepositoryHash() =>
    r'3cbdd853d5914334cb0d9dd87864bd543c321ea5';
