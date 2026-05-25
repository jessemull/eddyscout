import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// `developer.log` name for river routing diagnostics in debug builds.
const String kHydroDebugLogName = 'eddyscout.hydro';

/// Prints and logs [message] when [kDebugMode] is true.
void hydroDebugLog(String message) {
  if (kDebugMode) {
    debugPrint('[$kHydroDebugLogName] $message');
    developer.log(message, name: kHydroDebugLogName);
  }
}
