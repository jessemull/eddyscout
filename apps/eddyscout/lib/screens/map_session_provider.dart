import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the Mapbox map has finished style setup and launch markers are ready.
///
/// False blocks gestures until Mercator + launch fit completes.
final mapInteractiveProvider = StateProvider.autoDispose<bool>((ref) => false);
