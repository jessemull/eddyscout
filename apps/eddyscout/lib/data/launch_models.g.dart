// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LaunchFlowBands _$LaunchFlowBandsFromJson(Map<String, dynamic> json) =>
    _LaunchFlowBands(
      cfsMarginalBelow: (json['cfsMarginalBelow'] as num?)?.toDouble(),
      cfsComfortMax: (json['cfsComfortMax'] as num?)?.toDouble(),
      cfsNoGoAbove: (json['cfsNoGoAbove'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LaunchFlowBandsToJson(_LaunchFlowBands instance) =>
    <String, dynamic>{
      'cfsMarginalBelow': instance.cfsMarginalBelow,
      'cfsComfortMax': instance.cfsComfortMax,
      'cfsNoGoAbove': instance.cfsNoGoAbove,
    };

_LaunchPoint _$LaunchPointFromJson(Map<String, dynamic> json) => _LaunchPoint(
  id: json['id'] as String,
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  shortNote: json['shortNote'] as String,
  riverSystem: $enumDecode(_$RiverSystemEnumMap, json['riverSystem']),
  windExposure: $enumDecode(_$WindExposureEnumMap, json['windExposure']),
  tideRelevance: $enumDecode(_$TideRelevanceEnumMap, json['tideRelevance']),
  noaaTideStationId: json['noaaTideStationId'] as String?,
  marineZoneId: json['marineZoneId'] as String?,
  usgsSiteId: json['usgsSiteId'] as String?,
  flowBands: json['flowBands'] == null
      ? null
      : LaunchFlowBands.fromJson(json['flowBands'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LaunchPointToJson(_LaunchPoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'shortNote': instance.shortNote,
      'riverSystem': _$RiverSystemEnumMap[instance.riverSystem]!,
      'windExposure': _$WindExposureEnumMap[instance.windExposure]!,
      'tideRelevance': _$TideRelevanceEnumMap[instance.tideRelevance]!,
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
