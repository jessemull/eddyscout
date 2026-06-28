// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_report_moderation_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [ConditionReportModerationRepository] token.

@ProviderFor(conditionReportModerationRepository)
final conditionReportModerationRepositoryProvider =
    ConditionReportModerationRepositoryProvider._();

/// Injectable [ConditionReportModerationRepository] token.

final class ConditionReportModerationRepositoryProvider
    extends
        $FunctionalProvider<
          ConditionReportModerationRepository,
          ConditionReportModerationRepository,
          ConditionReportModerationRepository
        >
    with $Provider<ConditionReportModerationRepository> {
  /// Injectable [ConditionReportModerationRepository] token.
  ConditionReportModerationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionReportModerationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$conditionReportModerationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConditionReportModerationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionReportModerationRepository create(Ref ref) {
    return conditionReportModerationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionReportModerationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionReportModerationRepository>(
        value,
      ),
    );
  }
}

String _$conditionReportModerationRepositoryHash() =>
    r'0f6ce3dac25842cb4d3b27a8aa1bbdd4ca61ad12';
