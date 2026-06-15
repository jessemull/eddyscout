// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_no_go.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoNoGoReason _$GoNoGoReasonFromJson(Map<String, dynamic> json) =>
    _GoNoGoReason(
      code: $enumDecode(_$GoNoGoReasonCodeEnumMap, json['code']),
      severity: $enumDecode(_$GoNoGoReasonSeverityEnumMap, json['severity']),
      windMph: (json['windMph'] as num?)?.toInt(),
      exposure: json['exposure'] as String?,
      pattern: json['pattern'] as String?,
      cfs: json['cfs'] as String?,
      siteId: json['siteId'] as String?,
      weatherError: json['weatherError'] as String?,
      usesLaunchFlowBands: json['usesLaunchFlowBands'] as bool?,
    );

Map<String, dynamic> _$GoNoGoReasonToJson(_GoNoGoReason instance) =>
    <String, dynamic>{
      'code': _$GoNoGoReasonCodeEnumMap[instance.code]!,
      'severity': _$GoNoGoReasonSeverityEnumMap[instance.severity]!,
      'windMph': instance.windMph,
      'exposure': instance.exposure,
      'pattern': instance.pattern,
      'cfs': instance.cfs,
      'siteId': instance.siteId,
      'weatherError': instance.weatherError,
      'usesLaunchFlowBands': instance.usesLaunchFlowBands,
    };

const _$GoNoGoReasonCodeEnumMap = {
  GoNoGoReasonCode.coldWaterSeason: 'cold_water_season',
  GoNoGoReasonCode.weatherMissing: 'weather_missing',
  GoNoGoReasonCode.windUnknown: 'wind_unknown',
  GoNoGoReasonCode.windHigh: 'wind_high',
  GoNoGoReasonCode.windElevated: 'wind_elevated',
  GoNoGoReasonCode.marineSevere: 'marine_severe',
  GoNoGoReasonCode.marineAdvisory: 'marine_advisory',
  GoNoGoReasonCode.forecastLowLightHours: 'forecast_low_light_hours',
  GoNoGoReasonCode.flowVeryHigh: 'flow_very_high',
  GoNoGoReasonCode.flowHigh: 'flow_high',
  GoNoGoReasonCode.flowLow: 'flow_low',
};

const _$GoNoGoReasonSeverityEnumMap = {
  GoNoGoReasonSeverity.info: 'info',
  GoNoGoReasonSeverity.marginal: 'marginal',
  GoNoGoReasonSeverity.noGo: 'noGo',
};

_GoNoGoResult _$GoNoGoResultFromJson(Map<String, dynamic> json) =>
    _GoNoGoResult(
      verdict: $enumDecode(_$GoNoGoVerdictEnumMap, json['verdict']),
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => GoNoGoReason.fromJson(e as Map<String, dynamic>))
          .toList(),
      computedAt: DateTime.parse(json['computedAt'] as String),
    );

Map<String, dynamic> _$GoNoGoResultToJson(_GoNoGoResult instance) =>
    <String, dynamic>{
      'verdict': _$GoNoGoVerdictEnumMap[instance.verdict]!,
      'reasons': instance.reasons.map((e) => e.toJson()).toList(),
      'computedAt': instance.computedAt.toIso8601String(),
    };

const _$GoNoGoVerdictEnumMap = {
  GoNoGoVerdict.go: 'go',
  GoNoGoVerdict.marginal: 'marginal',
  GoNoGoVerdict.noGo: 'noGo',
  GoNoGoVerdict.insufficientData: 'insufficientData',
};
