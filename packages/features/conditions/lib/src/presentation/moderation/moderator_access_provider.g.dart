// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderator_access_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the signed-in user can open the moderation queue.

@ProviderFor(moderatorAccess)
final moderatorAccessProvider = ModeratorAccessProvider._();

/// Whether the signed-in user can open the moderation queue.

final class ModeratorAccessProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the signed-in user can open the moderation queue.
  ModeratorAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderatorAccessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderatorAccessHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return moderatorAccess(ref);
  }
}

String _$moderatorAccessHash() => r'62a0ae9b8dc21cfdc1cf9b7a842b661318dec7f7';
