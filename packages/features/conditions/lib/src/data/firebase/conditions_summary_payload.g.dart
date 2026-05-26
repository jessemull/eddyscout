// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_summary_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LaunchSummary _$LaunchSummaryFromJson(Map<String, dynamic> json) =>
    _LaunchSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      shortNote: json['shortNote'] as String,
      riverSystem: $enumDecode(_$RiverSystemEnumMap, json['riverSystem']),
      windExposure: $enumDecode(_$WindExposureEnumMap, json['windExposure']),
      tideRelevance: $enumDecode(_$TideRelevanceEnumMap, json['tideRelevance']),
      skillProfile: $enumDecode(_$GoNoGoProfileEnumMap, json['skillProfile']),
      noaaTideStationId: json['noaaTideStationId'] as String?,
      marineZoneId: json['marineZoneId'] as String?,
      usgsSiteId: json['usgsSiteId'] as String?,
      flowBands: json['flowBands'] == null
          ? null
          : LaunchFlowBands.fromJson(json['flowBands'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LaunchSummaryToJson(_LaunchSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'shortNote': instance.shortNote,
      'riverSystem': _$RiverSystemEnumMap[instance.riverSystem]!,
      'windExposure': _$WindExposureEnumMap[instance.windExposure]!,
      'tideRelevance': _$TideRelevanceEnumMap[instance.tideRelevance]!,
      'skillProfile': _$GoNoGoProfileEnumMap[instance.skillProfile]!,
      'noaaTideStationId': instance.noaaTideStationId,
      'marineZoneId': instance.marineZoneId,
      'usgsSiteId': instance.usgsSiteId,
      'flowBands': instance.flowBands?.toJson(),
    };

const _$RiverSystemEnumMap = {
  RiverSystem.willamette: 'willamette',
  RiverSystem.columbia: 'columbia',
  RiverSystem.clackamas: 'clackamas',
  RiverSystem.slough: 'slough',
};

const _$WindExposureEnumMap = {
  WindExposure.sheltered: 'sheltered',
  WindExposure.moderate: 'moderate',
  WindExposure.exposed: 'exposed',
};

const _$TideRelevanceEnumMap = {
  TideRelevance.none: 'none',
  TideRelevance.minor: 'minor',
  TideRelevance.major: 'major',
};

const _$GoNoGoProfileEnumMap = {
  GoNoGoProfile.beginner: 'beginner',
  GoNoGoProfile.intermediate: 'intermediate',
  GoNoGoProfile.advanced: 'advanced',
};

_ConditionsSummaryPayload _$ConditionsSummaryPayloadFromJson(
  Map<String, dynamic> json,
) => _ConditionsSummaryPayload(
  launch: LaunchSummary.fromJson(json['launch'] as Map<String, dynamic>),
  snapshot: ConditionsSnapshot.fromJson(
    json['snapshot'] as Map<String, dynamic>,
  ),
  goNoGo: GoNoGoResult.fromJson(json['goNoGo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConditionsSummaryPayloadToJson(
  _ConditionsSummaryPayload instance,
) => <String, dynamic>{
  'launch': instance.launch.toJson(),
  'snapshot': instance.snapshot.toJson(),
  'goNoGo': instance.goNoGo.toJson(),
};
