// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_no_go.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoNoGoReason _$GoNoGoReasonFromJson(Map<String, dynamic> json) =>
    _GoNoGoReason(
      code: json['code'] as String,
      message: json['message'] as String,
      severity: $enumDecode(_$GoNoGoReasonSeverityEnumMap, json['severity']),
    );

Map<String, dynamic> _$GoNoGoReasonToJson(_GoNoGoReason instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'severity': _$GoNoGoReasonSeverityEnumMap[instance.severity]!,
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
