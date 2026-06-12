import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_session_provider.g.dart';

/// Whether the Mapbox map finished style setup and launch markers are ready.
///
/// False blocks gestures until Mercator + launch fit completes.
@Riverpod(keepAlive: true)
class MapInteractive extends _$MapInteractive {
  @override
  bool build() => false;

  void markInteractive() => state = true;

  void resetInteractive() => state = false;
}

/// Increments when the map tab becomes active again (bottom nav).
///
/// Map route chrome listens to redraw saved/planned lines after offstage tabs.
@Riverpod(keepAlive: true)
class MapTabResumed extends _$MapTabResumed {
  @override
  int build() => 0;

  /// Notifies listeners that the map tab is visible again.
  void notifyResumed() => state++;
}
