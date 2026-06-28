// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_report_submit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Submits a paddler condition report via Firebase Callable.

@ProviderFor(ConditionReportSubmit)
final conditionReportSubmitProvider = ConditionReportSubmitFamily._();

/// Submits a paddler condition report via Firebase Callable.
final class ConditionReportSubmitProvider
    extends $AsyncNotifierProvider<ConditionReportSubmit, void> {
  /// Submits a paddler condition report via Firebase Callable.
  ConditionReportSubmitProvider._({
    required ConditionReportSubmitFamily super.from,
    required ConditionReportSubmitArgs super.argument,
  }) : super(
         retry: null,
         name: r'conditionReportSubmitProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conditionReportSubmitHash();

  @override
  String toString() {
    return r'conditionReportSubmitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConditionReportSubmit create() => ConditionReportSubmit();

  @override
  bool operator ==(Object other) {
    return other is ConditionReportSubmitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conditionReportSubmitHash() =>
    r'05edb8ff0554351e2f5dc2619ea6ff807e8e83d7';

/// Submits a paddler condition report via Firebase Callable.

final class ConditionReportSubmitFamily extends $Family
    with
        $ClassFamilyOverride<
          ConditionReportSubmit,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          ConditionReportSubmitArgs
        > {
  ConditionReportSubmitFamily._()
    : super(
        retry: null,
        name: r'conditionReportSubmitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Submits a paddler condition report via Firebase Callable.

  ConditionReportSubmitProvider call(ConditionReportSubmitArgs args) =>
      ConditionReportSubmitProvider._(argument: args, from: this);

  @override
  String toString() => r'conditionReportSubmitProvider';
}

/// Submits a paddler condition report via Firebase Callable.

abstract class _$ConditionReportSubmit extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as ConditionReportSubmitArgs;
  ConditionReportSubmitArgs get args => _$args;

  FutureOr<void> build(ConditionReportSubmitArgs args);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
