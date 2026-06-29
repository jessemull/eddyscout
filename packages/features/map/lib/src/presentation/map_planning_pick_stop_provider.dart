import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_planning_pick_stop_provider.g.dart';

/// Whether route planning is in full-map "choose on map" snap-stop mode.
@Riverpod(keepAlive: true)
class MapPlanningPickStopActive extends _$MapPlanningPickStopActive {
  @override
  bool build() => false;

  void enter() => state = true;

  void exit() => state = false;
}
