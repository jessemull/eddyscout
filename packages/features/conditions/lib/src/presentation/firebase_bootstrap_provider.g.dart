// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_bootstrap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session Firebase bootstrap outcome (overridden from app composition root).

@ProviderFor(firebaseBootstrap)
final firebaseBootstrapProvider = FirebaseBootstrapProvider._();

/// Session Firebase bootstrap outcome (overridden from app composition root).

final class FirebaseBootstrapProvider
    extends
        $FunctionalProvider<
          FirebaseBootstrapState,
          FirebaseBootstrapState,
          FirebaseBootstrapState
        >
    with $Provider<FirebaseBootstrapState> {
  /// Session Firebase bootstrap outcome (overridden from app composition root).
  FirebaseBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseBootstrapHash();

  @$internal
  @override
  $ProviderElement<FirebaseBootstrapState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseBootstrapState create(Ref ref) {
    return firebaseBootstrap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseBootstrapState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseBootstrapState>(value),
    );
  }
}

String _$firebaseBootstrapHash() => r'9cb8d473c554aaa53f346e131ce844b49ad9bf36';
