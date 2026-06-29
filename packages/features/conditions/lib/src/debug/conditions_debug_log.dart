import 'dart:developer' as developer;

import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/foundation.dart';

/// Prefix on every line so `flutter run` shows them (`debugPrint`).
///
/// Filter locally: `flutter run` stdout, or
/// `adb logcat -s flutter:I | rg eddyscout.conditions`
///
/// Enable in profile/release builds with dart-define CONDITIONS_DEBUG=true
const String kConditionsDebugLogName = 'eddyscout.conditions';

/// Whether conditions debug logging is enabled (debug builds or
/// CONDITIONS_DEBUG).
const bool kConditionsDebugEnabled =
    kDebugMode || bool.fromEnvironment('CONDITIONS_DEBUG');

/// Logs a conditions debug message when [kConditionsDebugEnabled].
void conditionsDebugLog(String message) {
  if (kConditionsDebugEnabled) {
    debugPrint('[$kConditionsDebugLogName] $message');
    developer.log(message, name: kConditionsDebugLogName);
  }
}

/// Logs a timestamped phase marker for conditions debugging.
void conditionsDebugLogTs(String phase) {
  if (kConditionsDebugEnabled) {
    conditionsDebugLog('TS ${DateTime.now().millisecondsSinceEpoch} | $phase');
  }
}

/// Logs launch metadata used when fetching conditions.
void conditionsDebugLogLaunch(String context, LaunchPoint launch) {
  if (!kConditionsDebugEnabled) {
    return;
  }
  conditionsDebugLog(
    '$context | launch=${launch.id} name="${launch.name}" '
    'usgs=${launch.usgsSiteId ?? 'none'} '
    'marine=${launch.marineZoneId ?? 'none'} '
    'tide=${launch.noaaTideStationId ?? 'none'}',
  );
}

/// Logs a fetched conditions snapshot summary for a launch.
void conditionsDebugLogSnapshot(
  String context,
  LaunchPoint launch,
  ConditionsSnapshot snapshot,
) {
  if (!kConditionsDebugEnabled) {
    return;
  }
  final weather = snapshot.weather;
  final flow = snapshot.riverFlow;
  final weatherPart = weather == null
      ? 'null'
      : '${weather.windSpeedMph}mph err=${snapshot.weatherError}';
  final riverPart = flow == null
      ? 'null'
      : '${flow.cfs}cfs@${flow.siteId} err=${snapshot.riverError}';
  final marinePart = snapshot.marine == null ? 'null' : snapshot.marine!.zoneId;
  conditionsDebugLog(
    '$context | launch=${launch.id} '
    'fetchedAt=${snapshot.fetchedAt.toIso8601String()} '
    'weather=$weatherPart river=$riverPart '
    'marine=$marinePart err=${snapshot.marineError} '
    'tides=${snapshot.tides?.stationId ?? 'null'}',
  );
}

/// Logs go/no-go evaluation output for a launch.
void conditionsDebugLogGoNoGo(
  String context,
  LaunchPoint launch,
  GoNoGoResult result,
) {
  if (!kConditionsDebugEnabled) {
    return;
  }
  final reasonSummary = result.reasons
      .map((r) => '${r.code.name}${r.cfs == null ? '' : '(cfs=${r.cfs})'}')
      .join(', ');
  conditionsDebugLog(
    '$context | launch=${launch.id} verdict=${result.verdict.name} '
    'reasons=${reasonSummary.isEmpty ? 'none' : reasonSummary}',
  );
}
