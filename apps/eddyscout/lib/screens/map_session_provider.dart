import 'package:flutter_riverpod/legacy.dart';

/// Whether the Mapbox map finished style setup and launch markers are ready.
///
/// False blocks gestures until Mercator + launch fit completes.
final StateProvider<bool> mapInteractiveProvider =
    StateProvider.autoDispose<bool>((ref) => false);
