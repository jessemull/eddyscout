// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_go_no_go_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Go/no-go evaluation for a launch and conditions snapshot.

@ProviderFor(launchGoNoGoResult)
final launchGoNoGoResultProvider = LaunchGoNoGoResultFamily._();

/// Go/no-go evaluation for a launch and conditions snapshot.

final class LaunchGoNoGoResultProvider
    extends $FunctionalProvider<GoNoGoResult, GoNoGoResult, GoNoGoResult>
    with $Provider<GoNoGoResult> {
  /// Go/no-go evaluation for a launch and conditions snapshot.
  LaunchGoNoGoResultProvider._({
    required LaunchGoNoGoResultFamily super.from,
    required LaunchGoNoGoParams super.argument,
  }) : super(
         retry: null,
         name: r'launchGoNoGoResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$launchGoNoGoResultHash();

  @override
  String toString() {
    return r'launchGoNoGoResultProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GoNoGoResult> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoNoGoResult create(Ref ref) {
    final argument = this.argument as LaunchGoNoGoParams;
    return launchGoNoGoResult(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoNoGoResult value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoNoGoResult>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LaunchGoNoGoResultProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$launchGoNoGoResultHash() =>
    r'ad782f52ebb2248922be7b2d7e1f2cb177693757';

/// Go/no-go evaluation for a launch and conditions snapshot.

final class LaunchGoNoGoResultFamily extends $Family
    with $FunctionalFamilyOverride<GoNoGoResult, LaunchGoNoGoParams> {
  LaunchGoNoGoResultFamily._()
    : super(
        retry: null,
        name: r'launchGoNoGoResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Go/no-go evaluation for a launch and conditions snapshot.

  LaunchGoNoGoResultProvider call(LaunchGoNoGoParams params) =>
      LaunchGoNoGoResultProvider._(argument: params, from: this);

  @override
  String toString() => r'launchGoNoGoResultProvider';
}
