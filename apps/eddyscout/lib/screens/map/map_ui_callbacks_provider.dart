import 'package:eddyscout/screens/map/map_ui_callbacks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Snackbar and navigation hooks set by the map screen each build.
final mapUiCallbacksProvider = StateProvider.autoDispose<MapUiCallbacks>(
  (ref) => const MapUiCallbacks(),
);
