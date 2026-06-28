import 'package:eddyscout_core/eddyscout_core.dart';

/// Resolves a human-readable launch label for moderation UI.
String resolveLaunchDisplayName(String launchId) {
  return findLaunchPointById(launchId)?.name ?? launchId;
}

/// Truncates a Firebase uid for compact display.
String truncateUid(String uid, {int length = 8}) {
  if (uid.length <= length) {
    return uid;
  }
  return uid.substring(0, length);
}
