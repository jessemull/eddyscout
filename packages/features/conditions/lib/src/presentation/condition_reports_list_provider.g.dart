// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_reports_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recent approved paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.

@ProviderFor(conditionReportsList)
final conditionReportsListProvider = ConditionReportsListFamily._();

/// Recent approved paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.

final class ConditionReportsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConditionReportsListResult>,
          ConditionReportsListResult,
          FutureOr<ConditionReportsListResult>
        >
    with
        $FutureModifier<ConditionReportsListResult>,
        $FutureProvider<ConditionReportsListResult> {
  /// Recent approved paddler reports for a launch.
  ///
  /// Refetches when [conditionReportsRefreshTokenProvider] changes.
  ConditionReportsListProvider._({
    required ConditionReportsListFamily super.from,
    required String super.argument,
  }) : super(
         retry: disableProviderRetry,
         name: r'conditionReportsListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conditionReportsListHash();

  @override
  String toString() {
    return r'conditionReportsListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ConditionReportsListResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConditionReportsListResult> create(Ref ref) {
    final argument = this.argument as String;
    return conditionReportsList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConditionReportsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conditionReportsListHash() =>
    r'0caffd87c5bc169ce0700c24430f5162b4e7698b';

/// Recent approved paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.

final class ConditionReportsListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ConditionReportsListResult>,
          String
        > {
  ConditionReportsListFamily._()
    : super(
        retry: disableProviderRetry,
        name: r'conditionReportsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recent approved paddler reports for a launch.
  ///
  /// Refetches when [conditionReportsRefreshTokenProvider] changes.

  ConditionReportsListProvider call(String launchId) =>
      ConditionReportsListProvider._(argument: launchId, from: this);

  @override
  String toString() => r'conditionReportsListProvider';
}
