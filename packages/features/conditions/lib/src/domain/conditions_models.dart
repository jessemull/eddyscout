import 'package:freezed_annotation/freezed_annotation.dart';

part 'conditions_models.freezed.dart';
part 'conditions_models.g.dart';

/// Which API supplied the weather card.
enum WeatherDataSource { nws, openMeteo }

extension WeatherDataSourceLabel on WeatherDataSource {
  String get displayName => switch (this) {
    WeatherDataSource.nws => 'National Weather Service',
    WeatherDataSource.openMeteo => 'Open-Meteo',
  };
}

@freezed
abstract class WeatherConditions with _$WeatherConditions {
  const factory WeatherConditions({
    required WeatherDataSource source,
    int? temperatureF,
    int? windSpeedMph,
    int? windGustMph,
    String? windDirection,
    String? shortForecast,
    DateTime? periodStart,
  }) = _WeatherConditions;

  factory WeatherConditions.fromJson(Map<String, dynamic> json) =>
      _$WeatherConditionsFromJson(json);
}

@freezed
abstract class TideEvent with _$TideEvent {
  const factory TideEvent({
    required String type,
    required DateTime time,
    double? heightFt,
  }) = _TideEvent;

  factory TideEvent.fromJson(Map<String, dynamic> json) =>
      _$TideEventFromJson(json);
}

@freezed
abstract class TideSummary with _$TideSummary {
  const factory TideSummary({
    required String stationId,
    required String datumLabel,
    required List<TideEvent> events,
    String? referenceNote,
  }) = _TideSummary;

  factory TideSummary.fromJson(Map<String, dynamic> json) =>
      _$TideSummaryFromJson(json);
}

@freezed
abstract class MarinePeriod with _$MarinePeriod {
  const factory MarinePeriod({
    required String name,
    required String detailedForecast,
  }) = _MarinePeriod;

  factory MarinePeriod.fromJson(Map<String, dynamic> json) =>
      _$MarinePeriodFromJson(json);
}

@freezed
abstract class MarineSummary with _$MarineSummary {
  const factory MarineSummary({
    required String zoneId,
    required List<MarinePeriod> periods,
  }) = _MarineSummary;

  factory MarineSummary.fromJson(Map<String, dynamic> json) =>
      _$MarineSummaryFromJson(json);
}

@freezed
abstract class RiverFlowReading with _$RiverFlowReading {
  const factory RiverFlowReading({
    required String siteId,
    required double cfs,
    required DateTime observedAt,
  }) = _RiverFlowReading;

  factory RiverFlowReading.fromJson(Map<String, dynamic> json) =>
      _$RiverFlowReadingFromJson(json);
}

/// Aggregated conditions for one launch (partial success allowed).
@freezed
abstract class ConditionsSnapshot with _$ConditionsSnapshot {
  const factory ConditionsSnapshot({
    required DateTime fetchedAt,
    WeatherConditions? weather,
    String? weatherError,
    TideSummary? tides,
    String? tideError,
    MarineSummary? marine,
    String? marineError,
    RiverFlowReading? riverFlow,
    String? riverError,
  }) = _ConditionsSnapshot;

  factory ConditionsSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ConditionsSnapshotFromJson(json);
}
