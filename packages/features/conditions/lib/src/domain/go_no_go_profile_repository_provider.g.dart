// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_no_go_profile_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [GoNoGoProfileRepository] token for presentation and data.
///
/// Bound at the app composition root. Tests override with a mock or fake.

@ProviderFor(goNoGoProfileRepository)
final goNoGoProfileRepositoryProvider = GoNoGoProfileRepositoryProvider._();

/// Injectable [GoNoGoProfileRepository] token for presentation and data.
///
/// Bound at the app composition root. Tests override with a mock or fake.

final class GoNoGoProfileRepositoryProvider
    extends
        $FunctionalProvider<
          GoNoGoProfileRepository,
          GoNoGoProfileRepository,
          GoNoGoProfileRepository
        >
    with $Provider<GoNoGoProfileRepository> {
  /// Injectable [GoNoGoProfileRepository] token for presentation and data.
  ///
  /// Bound at the app composition root. Tests override with a mock or fake.
  GoNoGoProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goNoGoProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goNoGoProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoNoGoProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoNoGoProfileRepository create(Ref ref) {
    return goNoGoProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoNoGoProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoNoGoProfileRepository>(value),
    );
  }
}

String _$goNoGoProfileRepositoryHash() =>
    r'5343b6378e62a7d26730fd64eebae537320c8853';
