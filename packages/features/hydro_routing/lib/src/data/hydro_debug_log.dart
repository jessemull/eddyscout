import 'dart:developer' as developer;

/// `developer.log` name for river routing diagnostics in debug builds.
const String kHydroDebugLogName = 'eddyscout.hydro';

/// Logs [message] in debug builds (assert-enabled); no-op in release.
void hydroDebugLog(String message) {
  assert(() {
    // VM and Flutter debug builds only; avoids flutter/foundation dependency.
    // ignore: avoid_print
    print('[$kHydroDebugLogName] $message');
    developer.log(message, name: kHydroDebugLogName);
    return true;
  }(), 'hydroDebugLog runs only in debug builds');
}
