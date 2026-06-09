import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_sheet_provider.g.dart';

/// Bottom sheet visibility on the map tab.
enum MapSheetVisibility {
  /// No sheet — map browse only.
  hidden,

  /// Place summary sheet (peek height).
  placePeek,

  /// Route planning sheet (expanded).
  planningExpanded,
}

/// Currently selected launch for the place / planning sheets.
@Riverpod(keepAlive: true)
class MapPlaceSelection extends _$MapPlaceSelection {
  @override
  LaunchPoint? build() => null;

  // ignore: use_setters_to_change_properties — Riverpod notifier API
  void pickLaunch(LaunchPoint launch) => state = launch;

  void clear() => state = null;
}

/// Controls which bottom sheet variant is shown on the map.
@Riverpod(keepAlive: true)
class MapSheetVisibilityState extends _$MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.hidden;

  void showPlacePeek() => state = MapSheetVisibility.placePeek;

  void showPlanningExpanded() => state = MapSheetVisibility.planningExpanded;

  void hide() => state = MapSheetVisibility.hidden;
}
