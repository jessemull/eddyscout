import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/conditions_models.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import '../../domain/go_no_go.dart';

part 'conditions_summary_payload.freezed.dart';
part 'conditions_summary_payload.g.dart';

/// Launch fields plus skill profile for Cloud Functions JSON (camelCase).
@freezed
abstract class LaunchSummary with _$LaunchSummary {
  const factory LaunchSummary({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String shortNote,
    required RiverSystem riverSystem,
    required WindExposure windExposure,
    required TideRelevance tideRelevance,
    String? noaaTideStationId,
    String? marineZoneId,
    String? usgsSiteId,
    LaunchFlowBands? flowBands,
    required GoNoGoProfile skillProfile,
  }) = _LaunchSummary;

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

  factory LaunchSummary.fromJson(Map<String, dynamic> json) =>
      _$LaunchSummaryFromJson(json);
}

/// JSON-safe payload for Cloud Functions (`summarizeConditions`) and logging.
///
/// Keep in sync with `firebase/functions` zod schema.
@freezed
abstract class ConditionsSummaryPayload with _$ConditionsSummaryPayload {
  const factory ConditionsSummaryPayload({
    required LaunchSummary launch,
    required ConditionsSnapshot snapshot,
    required GoNoGoResult goNoGo,
  }) = _ConditionsSummaryPayload;

  factory ConditionsSummaryPayload.fromJson(Map<String, dynamic> json) =>
      _$ConditionsSummaryPayloadFromJson(json);
}

/// Builds the map sent to `summarizeConditions` (camelCase keys).
Map<String, Object?> conditionsSummaryPayload({
  required LaunchPoint launch,
  required ConditionsSnapshot snapshot,
  required GoNoGoResult goNoGo,
  required GoNoGoProfile skillProfile,
}) {
  return ConditionsSummaryPayload(
    launch: LaunchSummary.fromLaunchPoint(launch, skillProfile),
    snapshot: snapshot,
    goNoGo: goNoGo,
  ).toJson();
}
