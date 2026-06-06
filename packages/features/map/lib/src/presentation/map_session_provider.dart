import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_session_provider.g.dart';

/// Whether the Mapbox map finished style setup and launch markers are ready.
///
/// False blocks gestures until Mercator + launch fit completes.
@riverpod
class MapInteractive extends _$MapInteractive {
  @override
  bool build() => false;

  void markInteractive() => state = true;
}
