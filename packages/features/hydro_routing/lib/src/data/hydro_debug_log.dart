import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

const String kHydroDebugLogName = 'eddyscout.hydro';

void hydroDebugLog(String message) {
  if (kDebugMode) {
    debugPrint('[$kHydroDebugLogName] $message');
    developer.log(message, name: kHydroDebugLogName);
  }
}
