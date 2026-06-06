// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves a curated launch by id.
///
/// Throws [NotFoundFailure] when [id] is not in the catalog.

@ProviderFor(launchPointById)
final launchPointByIdProvider = LaunchPointByIdFamily._();

/// Resolves a curated launch by id.
///
/// Throws [NotFoundFailure] when [id] is not in the catalog.

final class LaunchPointByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<LaunchPoint>,
          LaunchPoint,
          FutureOr<LaunchPoint>
        >
    with $FutureModifier<LaunchPoint>, $FutureProvider<LaunchPoint> {
  /// Resolves a curated launch by id.
  ///
  /// Throws [NotFoundFailure] when [id] is not in the catalog.
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
  $FutureProviderElement<LaunchPoint> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LaunchPoint> create(Ref ref) {
    final argument = this.argument as String;
    return launchPointById(ref, argument);
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

String _$launchPointByIdHash() => r'2d8fb755172796694b54a3ace37e8d7701be45d9';

/// Resolves a curated launch by id.
///
/// Throws [NotFoundFailure] when [id] is not in the catalog.

final class LaunchPointByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LaunchPoint>, String> {
  LaunchPointByIdFamily._()
    : super(
        retry: null,
        name: r'launchPointByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Resolves a curated launch by id.
  ///
  /// Throws [NotFoundFailure] when [id] is not in the catalog.

  LaunchPointByIdProvider call(String id) =>
      LaunchPointByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'launchPointByIdProvider';
}
