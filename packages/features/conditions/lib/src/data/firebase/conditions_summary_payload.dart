import 'package:eddyscout_conditions/src/data/firebase/go_no_go_reason_fallback_message.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conditions_summary_payload.freezed.dart';
part 'conditions_summary_payload.g.dart';

/// Launch fields plus skill profile for Cloud Functions JSON (camelCase).
@freezed
abstract class LaunchSummary with _$LaunchSummary {
  /// Creates the launch slice sent to `summarizeConditions`.
  const factory LaunchSummary({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String shortNote,
    required RiverSystem riverSystem,
    required WindExposure windExposure,
    required TideRelevance tideRelevance,
    required GoNoGoProfile skillProfile,
    String? noaaTideStationId,
    String? marineZoneId,
    String? usgsSiteId,
    LaunchFlowBands? flowBands,
  }) = _LaunchSummary;

  /// Maps a [LaunchPoint] and skill profile into Callable JSON shape.
  factory LaunchSummary.fromLaunchPoint(
    LaunchPoint launch,
    GoNoGoProfile skillProfile,
  ) => LaunchSummary(
    id: launch.id,
    name: launch.name,
    latitude: launch.latitude,
    longitude: launch.longitude,
    shortNote: launch.shortNote,
    riverSystem: launch.riverSystem,
    windExposure: launch.windExposure,
    tideRelevance: launch.tideRelevance,
    noaaTideStationId: launch.noaaTideStationId,
    marineZoneId: launch.marineZoneId,
    usgsSiteId: launch.usgsSiteId,
    flowBands: launch.flowBands,
    skillProfile: skillProfile,
  );

  /// Parses launch summary from Callable JSON.
  factory LaunchSummary.fromJson(Map<String, dynamic> json) =>
      _$LaunchSummaryFromJson(json);
}

/// JSON-safe payload for Cloud Functions (`summarizeConditions`) and logging.
///
/// Keep in sync with `firebase/functions` zod schema.
@freezed
abstract class ConditionsSummaryPayload with _$ConditionsSummaryPayload {
  /// Creates the full summarizeConditions request body.
  const factory ConditionsSummaryPayload({
    required LaunchSummary launch,
    required ConditionsSnapshot snapshot,
    required GoNoGoResult goNoGo,
  }) = _ConditionsSummaryPayload;

  /// Parses summarizeConditions payload from JSON.
  factory ConditionsSummaryPayload.fromJson(Map<String, dynamic> json) =>
      _$ConditionsSummaryPayloadFromJson(json);
}

/// Builds the map sent to `summarizeConditions` (camelCase keys).
///
/// Combines launch metadata, snapshot, go/no-go, and skill profile.
Map<String, Object?> conditionsSummaryPayload({
  required LaunchPoint launch,
  required ConditionsSnapshot snapshot,
  required GoNoGoResult goNoGo,
  required GoNoGoProfile skillProfile,
}) {
  final payload = ConditionsSummaryPayload(
    launch: LaunchSummary.fromLaunchPoint(launch, skillProfile),
    snapshot: snapshot,
    goNoGo: goNoGo,
  ).toJson();

  final goNoGoMap = payload['goNoGo']! as Map<String, Object?>;
  final reasons = goNoGoMap['reasons']! as List<Object?>;
  goNoGoMap['reasons'] = reasons.map(_reasonJsonWithFallbackMessage).toList();

  return payload;
}

Map<String, Object?> _reasonJsonWithFallbackMessage(Object? raw) {
  final reasonMap = Map<String, Object?>.from(raw! as Map);
  final reason = GoNoGoReason.fromJson(
    Map<String, dynamic>.from(reasonMap),
  );
  return {
    ...reasonMap,
    'message': goNoGoReasonFallbackMessage(reason),
  };
}
