// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeatherConditions _$WeatherConditionsFromJson(Map<String, dynamic> json) =>
    _WeatherConditions(
      source: $enumDecode(_$WeatherDataSourceEnumMap, json['source']),
      temperatureF: (json['temperatureF'] as num?)?.toInt(),
      windSpeedMph: (json['windSpeedMph'] as num?)?.toInt(),
      windGustMph: (json['windGustMph'] as num?)?.toInt(),
      windDirection: json['windDirection'] as String?,
      shortForecast: json['shortForecast'] as String?,
      periodStart: json['periodStart'] == null
          ? null
          : DateTime.parse(json['periodStart'] as String),
    );

Map<String, dynamic> _$WeatherConditionsToJson(_WeatherConditions instance) =>
    <String, dynamic>{
      'source': _$WeatherDataSourceEnumMap[instance.source]!,
      'temperatureF': instance.temperatureF,
      'windSpeedMph': instance.windSpeedMph,
      'windGustMph': instance.windGustMph,
      'windDirection': instance.windDirection,
      'shortForecast': instance.shortForecast,
      'periodStart': instance.periodStart?.toIso8601String(),
    };

const _$WeatherDataSourceEnumMap = {
  WeatherDataSource.nws: 'nws',
  WeatherDataSource.openMeteo: 'openMeteo',
};

_TideEvent _$TideEventFromJson(Map<String, dynamic> json) => _TideEvent(
  type: json['type'] as String,
  time: DateTime.parse(json['time'] as String),
  heightFt: (json['heightFt'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TideEventToJson(_TideEvent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'time': instance.time.toIso8601String(),
      'heightFt': instance.heightFt,
    };

_TideSummary _$TideSummaryFromJson(Map<String, dynamic> json) => _TideSummary(
  stationId: json['stationId'] as String,
  datumLabel: json['datumLabel'] as String,
  events: (json['events'] as List<dynamic>)
      .map((e) => TideEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  referenceNote: json['referenceNote'] as String?,
);

Map<String, dynamic> _$TideSummaryToJson(_TideSummary instance) =>
    <String, dynamic>{
      'stationId': instance.stationId,
      'datumLabel': instance.datumLabel,
      'events': instance.events.map((e) => e.toJson()).toList(),
      'referenceNote': instance.referenceNote,
    };

_MarinePeriod _$MarinePeriodFromJson(Map<String, dynamic> json) =>
    _MarinePeriod(
      name: json['name'] as String,
      detailedForecast: json['detailedForecast'] as String,
    );

Map<String, dynamic> _$MarinePeriodToJson(_MarinePeriod instance) =>
    <String, dynamic>{
      'name': instance.name,
      'detailedForecast': instance.detailedForecast,
    };

_MarineSummary _$MarineSummaryFromJson(Map<String, dynamic> json) =>
    _MarineSummary(
      zoneId: json['zoneId'] as String,
      periods: (json['periods'] as List<dynamic>)
          .map((e) => MarinePeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MarineSummaryToJson(_MarineSummary instance) =>
    <String, dynamic>{
      'zoneId': instance.zoneId,
      'periods': instance.periods.map((e) => e.toJson()).toList(),
    };

_RiverFlowReading _$RiverFlowReadingFromJson(Map<String, dynamic> json) =>
    _RiverFlowReading(
      siteId: json['siteId'] as String,
      cfs: (json['cfs'] as num).toDouble(),
      observedAt: DateTime.parse(json['observedAt'] as String),
    );

Map<String, dynamic> _$RiverFlowReadingToJson(_RiverFlowReading instance) =>
    <String, dynamic>{
      'siteId': instance.siteId,
      'cfs': instance.cfs,
      'observedAt': instance.observedAt.toIso8601String(),
    };

_ConditionsSnapshot _$ConditionsSnapshotFromJson(Map<String, dynamic> json) =>
    _ConditionsSnapshot(
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      weather: json['weather'] == null
          ? null
          : WeatherConditions.fromJson(json['weather'] as Map<String, dynamic>),
      weatherError: json['weatherError'] as String?,
      tides: json['tides'] == null
          ? null
          : TideSummary.fromJson(json['tides'] as Map<String, dynamic>),
      tideError: json['tideError'] as String?,
      marine: json['marine'] == null
          ? null
          : MarineSummary.fromJson(json['marine'] as Map<String, dynamic>),
      marineError: json['marineError'] as String?,
      riverFlow: json['riverFlow'] == null
          ? null
          : RiverFlowReading.fromJson(
              json['riverFlow'] as Map<String, dynamic>,
            ),
      riverError: json['riverError'] as String?,
    );

Map<String, dynamic> _$ConditionsSnapshotToJson(_ConditionsSnapshot instance) =>
    <String, dynamic>{
      'fetchedAt': instance.fetchedAt.toIso8601String(),
      'weather': instance.weather?.toJson(),
      'weatherError': instance.weatherError,
      'tides': instance.tides?.toJson(),
      'tideError': instance.tideError,
      'marine': instance.marine?.toJson(),
      'marineError': instance.marineError,
      'riverFlow': instance.riverFlow?.toJson(),
      'riverError': instance.riverError,
    };
