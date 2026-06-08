// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_snapshot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads environmental conditions for a launch.

@ProviderFor(conditionsSnapshot)
final conditionsSnapshotProvider = ConditionsSnapshotFamily._();

/// Loads environmental conditions for a launch.

final class ConditionsSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConditionsSnapshot>,
          ConditionsSnapshot,
          FutureOr<ConditionsSnapshot>
        >
    with
        $FutureModifier<ConditionsSnapshot>,
        $FutureProvider<ConditionsSnapshot> {
  /// Loads environmental conditions for a launch.
  ConditionsSnapshotProvider._({
    required ConditionsSnapshotFamily super.from,
    required LaunchPoint super.argument,
  }) : super(
         retry: disableProviderRetry,
         name: r'conditionsSnapshotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conditionsSnapshotHash();

  @override
  String toString() {
    return r'conditionsSnapshotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ConditionsSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConditionsSnapshot> create(Ref ref) {
    final argument = this.argument as LaunchPoint;
    return conditionsSnapshot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConditionsSnapshotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conditionsSnapshotHash() =>
    r'1b538b5cb12ab4bccfc8f49530980abffb7e6423';

/// Loads environmental conditions for a launch.

final class ConditionsSnapshotFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ConditionsSnapshot>, LaunchPoint> {
  ConditionsSnapshotFamily._()
    : super(
        retry: disableProviderRetry,
        name: r'conditionsSnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads environmental conditions for a launch.

  ConditionsSnapshotProvider call(LaunchPoint launch) =>
      ConditionsSnapshotProvider._(argument: launch, from: this);

  @override
  String toString() => r'conditionsSnapshotProvider';
}
