import 'dart:math';

/// Generates a unique local id for a saved route (no external uuid package).
String generateSavedRouteId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final suffix = _secureRandomHex(8);
  return 'sr_${timestamp}_$suffix';
}

String _secureRandomHex(int byteCount) {
  final random = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < byteCount; i++) {
    buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
