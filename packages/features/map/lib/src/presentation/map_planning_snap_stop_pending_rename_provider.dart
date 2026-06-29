import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_planning_snap_stop_pending_rename_provider.g.dart';

/// Snap stop id that should open in rename edit mode when planning chrome
/// appears.
@Riverpod(keepAlive: true)
class MapPlanningSnapStopPendingRename
    extends _$MapPlanningSnapStopPendingRename {
  @override
  String? build() => null;

  String? get pendingStopId => state;

  set pendingStopId(String stopId) => state = stopId;

  void clear() => state = null;
}
