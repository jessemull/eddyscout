// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves a curated launch by id.

@ProviderFor(launchPointById)
final launchPointByIdProvider = LaunchPointByIdFamily._();

/// Resolves a curated launch by id.

final class LaunchPointByIdProvider
    extends
        $FunctionalProvider<
          Result<LaunchPoint, AppFailure>,
          Result<LaunchPoint, AppFailure>,
          Result<LaunchPoint, AppFailure>
        >
    with $Provider<Result<LaunchPoint, AppFailure>> {
  /// Resolves a curated launch by id.
  LaunchPointByIdProvider._({
    required LaunchPointByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'launchPointByIdProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$launchPointByIdHash();

  @override
  String toString() {
    return r'launchPointByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Result<LaunchPoint, AppFailure>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Result<LaunchPoint, AppFailure> create(Ref ref) {
    final argument = this.argument as String;
    return launchPointById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Result<LaunchPoint, AppFailure> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Result<LaunchPoint, AppFailure>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LaunchPointByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$launchPointByIdHash() => r'd32419bc264c8076c1377fbcff7e45571dde027f';

/// Resolves a curated launch by id.

final class LaunchPointByIdFamily extends $Family
    with $FunctionalFamilyOverride<Result<LaunchPoint, AppFailure>, String> {
  LaunchPointByIdFamily._()
    : super(
        retry: null,
        name: r'launchPointByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Resolves a curated launch by id.

  LaunchPointByIdProvider call(String id) =>
      LaunchPointByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'launchPointByIdProvider';
}
