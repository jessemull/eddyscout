// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_planning_snap_stop_pending_rename_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Snap stop id that should open in rename edit mode when planning chrome
/// appears.

@ProviderFor(MapPlanningSnapStopPendingRename)
final mapPlanningSnapStopPendingRenameProvider =
    MapPlanningSnapStopPendingRenameProvider._();

/// Snap stop id that should open in rename edit mode when planning chrome
/// appears.
final class MapPlanningSnapStopPendingRenameProvider
    extends $NotifierProvider<MapPlanningSnapStopPendingRename, String?> {
  /// Snap stop id that should open in rename edit mode when planning chrome
  /// appears.
  MapPlanningSnapStopPendingRenameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapPlanningSnapStopPendingRenameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapPlanningSnapStopPendingRenameHash();

  @$internal
  @override
  MapPlanningSnapStopPendingRename create() =>
      MapPlanningSnapStopPendingRename();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$mapPlanningSnapStopPendingRenameHash() =>
    r'142efad486a2c0705882395487541d29d196e0da';

/// Snap stop id that should open in rename edit mode when planning chrome
/// appears.

abstract class _$MapPlanningSnapStopPendingRename extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
