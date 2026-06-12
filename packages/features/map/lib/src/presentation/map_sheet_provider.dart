import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_sheet_provider.g.dart';

/// Map chrome visibility for place peek, planning edit, and route preview.
enum MapSheetVisibility {
  /// No sheet — map browse only.
  hidden,

  /// Compact place summary at the bottom.
  placePeek,

  /// Top edit-stops panel while building a route.
  planningEdit,

  /// Bottom preview bar after Done (Google Maps style).
  planningPreview,
}

/// Currently selected launch for the place peek sheet.
@Riverpod(keepAlive: true)
class MapPlaceSelection extends _$MapPlaceSelection {
  @override
  LaunchPoint? build() => null;

  // ignore: use_setters_to_change_properties — Riverpod notifier API
  void pickLaunch(LaunchPoint launch) => state = launch;

  void clear() => state = null;
}

/// Controls which map chrome variant is shown.
@Riverpod(keepAlive: true)
class MapSheetVisibilityState extends _$MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.hidden;

  void showPlacePeek() => state = MapSheetVisibility.placePeek;

  void showPlanningEdit() => state = MapSheetVisibility.planningEdit;

  void showPlanningPreview() => state = MapSheetVisibility.planningPreview;

  void hide() => state = MapSheetVisibility.hidden;
}
