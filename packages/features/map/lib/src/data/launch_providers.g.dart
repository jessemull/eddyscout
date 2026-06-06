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
    extends $FunctionalProvider<LaunchPoint, LaunchPoint, LaunchPoint>
    with $Provider<LaunchPoint> {
  /// Resolves a curated launch by id.
  LaunchPointByIdProvider._({
    required LaunchPointByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'launchPointByIdProvider',
         isAutoDispose: true,
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
  $ProviderElement<LaunchPoint> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LaunchPoint create(Ref ref) {
    final argument = this.argument as String;
    return launchPointById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchPoint value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchPoint>(value),
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

String _$launchPointByIdHash() => r'2045837c7d10dc4b11eb5580e6cdbadf270d36cd';

/// Resolves a curated launch by id.

final class LaunchPointByIdFamily extends $Family
    with $FunctionalFamilyOverride<LaunchPoint, String> {
  LaunchPointByIdFamily._()
    : super(
        retry: null,
        name: r'launchPointByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves a curated launch by id.

  LaunchPointByIdProvider call(String id) =>
      LaunchPointByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'launchPointByIdProvider';
}
