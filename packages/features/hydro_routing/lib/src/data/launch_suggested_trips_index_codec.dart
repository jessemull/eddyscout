import 'dart:convert';

import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_suggested_trips_index.dart';

/// Parses a bundled suggested trips index JSON document.
LaunchSuggestedTripsIndex parseLaunchSuggestedTripsIndex(String jsonText) {
  final root = jsonDecode(jsonText) as Map<String, dynamic>;
  final entriesRaw = root['entries'] as Map<String, dynamic>? ?? {};
  final entries = <String, LaunchSuggestedTripsEntry>{};
  for (final entry in entriesRaw.entries) {
    final value = entry.value as Map<String, dynamic>;
    entries[entry.key] = LaunchSuggestedTripsEntry(
      oneWay: _tripList(value['oneWay']),
      roundTrips: _tripList(value['roundTrips']),
    );
  }

  return LaunchSuggestedTripsIndex(
    schemaVersion: (root['schemaVersion'] as num?)?.toInt() ?? 1,
    generatedAt: DateTime.parse(root['generatedAt'] as String),
    distanceModel: root['distanceModel'] as String? ?? 'graph_plus_snap',
    snapMaxMeters:
        (root['snapMaxMeters'] as num?)?.toDouble() ??
        kReachabilitySnapMaxMeters,
    maxDistanceMi:
        (root['maxDistanceMi'] as num?)?.toInt() ??
        kSuggestedTripsMaxDistanceMi,
    paddleSpeedKmh:
        (root['paddleSpeedKmh'] as num?)?.toDouble() ??
        kSuggestedTripsDefaultPaddleSpeedKmh,
    maxOneWaySuggestions:
        (root['maxOneWaySuggestions'] as num?)?.toInt() ??
        kSuggestedTripsMaxOneWay,
    maxRoundTripSuggestions:
        (root['maxRoundTripSuggestions'] as num?)?.toInt() ??
        kSuggestedTripsMaxRoundTrip,
    crossSystemReachability: root['crossSystemReachability'] as bool? ?? false,
    entries: entries,
  );
}

/// Encodes [index] to stable, pretty-printed JSON for committed artifacts.
String encodeLaunchSuggestedTripsIndex(LaunchSuggestedTripsIndex index) {
  final entries = <String, dynamic>{};
  final sortedLaunchIds = index.entries.keys.toList()..sort();
  for (final launchId in sortedLaunchIds) {
    final entry = index.entries[launchId]!;
    entries[launchId] = {
      'oneWay': entry.oneWay.map(_encodeTrip).toList(),
      'roundTrips': entry.roundTrips.map(_encodeTrip).toList(),
    };
  }

  final root = <String, dynamic>{
    'schemaVersion': index.schemaVersion,
    'generatedAt': index.generatedAt.toUtc().toIso8601String(),
    'distanceModel': index.distanceModel,
    'snapMaxMeters': index.snapMaxMeters,
    'maxDistanceMi': index.maxDistanceMi,
    'paddleSpeedKmh': index.paddleSpeedKmh,
    'maxOneWaySuggestions': index.maxOneWaySuggestions,
    'maxRoundTripSuggestions': index.maxRoundTripSuggestions,
    'crossSystemReachability': index.crossSystemReachability,
    'entries': entries,
  };
  return const JsonEncoder.withIndent('  ').convert(root);
}

Map<String, dynamic> _encodeTrip(SuggestedTrip trip) {
  return {
    'destination': trip.destination,
    'distanceKm': _roundDistanceKm(trip.distanceKm),
    'estimatedMinutes': trip.estimatedMinutes,
    'waypoints': List<String>.from(trip.waypoints),
  };
}

double _roundDistanceKm(double distanceKm) {
  return (distanceKm * 10).round() / 10;
}

List<SuggestedTrip> _tripList(Object? value) {
  if (value is! List<dynamic>) {
    return const [];
  }
  return value.map(_parseTrip).toList();
}

SuggestedTrip _parseTrip(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Expected suggested trip object, got $value');
  }
  final map = value;
  return SuggestedTrip(
    destination: map['destination'] as String,
    distanceKm: (map['distanceKm'] as num).toDouble(),
    estimatedMinutes: (map['estimatedMinutes'] as num).toInt(),
    waypoints: (map['waypoints'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
  );
}
