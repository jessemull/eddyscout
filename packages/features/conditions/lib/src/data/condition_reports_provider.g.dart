// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recent paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.

@ProviderFor(conditionReportsList)
final conditionReportsListProvider = ConditionReportsListFamily._();

/// Recent paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.

final class ConditionReportsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConditionReportListItem>>,
          List<ConditionReportListItem>,
          FutureOr<List<ConditionReportListItem>>
        >
    with
        $FutureModifier<List<ConditionReportListItem>>,
        $FutureProvider<List<ConditionReportListItem>> {
  /// Recent paddler reports for a launch.
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
  $FutureProviderElement<List<ConditionReportListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConditionReportListItem>> create(Ref ref) {
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
    r'd0b9bda53dd38863ed79471b2364e7bb5c69e01c';

/// Recent paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.

final class ConditionReportsListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ConditionReportListItem>>,
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

  /// Recent paddler reports for a launch.
  ///
  /// Refetches when [conditionReportsRefreshTokenProvider] changes.

  ConditionReportsListProvider call(String launchId) =>
      ConditionReportsListProvider._(argument: launchId, from: this);

  @override
  String toString() => r'conditionReportsListProvider';
}
