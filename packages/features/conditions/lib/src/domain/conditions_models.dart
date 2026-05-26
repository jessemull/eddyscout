import 'package:freezed_annotation/freezed_annotation.dart';

part 'conditions_models.freezed.dart';
part 'conditions_models.g.dart';

/// Which API supplied the weather card.
enum WeatherDataSource {
  /// National Weather Service hourly forecast.
  nws,

  /// Open-Meteo fallback when NWS is unavailable.
  openMeteo,
}

/// Current weather from NWS or Open-Meteo for go/no-go wind rules.
@freezed
abstract class WeatherConditions with _$WeatherConditions {
  /// Creates parsed weather fields for one forecast period.
  const factory WeatherConditions({
    /// Data source used for this card.
    required WeatherDataSource source,

    /// Air temperature in °F when available.
    int? temperatureF,

    /// Sustained wind in mph when available.
    int? windSpeedMph,

    /// Wind gust in mph when available.
    int? windGustMph,

    /// Compass or cardinal wind direction label.
    String? windDirection,

    /// Short NWS phrase or Open-Meteo summary line.
    String? shortForecast,

    /// Start of the forecast period used for wind (local time).
    DateTime? periodStart,
  }) = _WeatherConditions;

  /// Parses weather from JSON (e.g. cached snapshot).
  factory WeatherConditions.fromJson(Map<String, dynamic> json) =>
      _$WeatherConditionsFromJson(json);
}

/// One high or low tide event from NOAA predictions.
@freezed
abstract class TideEvent with _$TideEvent {
  /// Creates a single tide event.
  const factory TideEvent({
    /// NOAA event type (e.g. H, L).
    required String type,

    /// Local or station time for the event.
    required DateTime time,

    /// Predicted height in feet when present.
    double? heightFt,
  }) = _TideEvent;

  /// Parses a tide event from JSON.
  factory TideEvent.fromJson(Map<String, dynamic> json) =>
      _$TideEventFromJson(json);
}

/// Tide high/low list for a NOAA station and datum.
@freezed
abstract class TideSummary with _$TideSummary {
  /// Creates tide summary for one station fetch.
  const factory TideSummary({
    /// NOAA station identifier.
    required String stationId,

    /// Datum label (e.g. CRD, MLLW).
    required String datumLabel,

    /// Upcoming high/low events in the fetch window.
    required List<TideEvent> events,

    /// Optional caveat for pool / lagged stage launches.
    String? referenceNote,
  }) = _TideSummary;

  /// Parses tide summary from JSON.
  factory TideSummary.fromJson(Map<String, dynamic> json) =>
      _$TideSummaryFromJson(json);
}

/// One period block from a marine zone or CWF text extract.
@freezed
abstract class MarinePeriod with _$MarinePeriod {
  /// Creates a named marine forecast period.
  const factory MarinePeriod({
    /// Period name from NWS JSON or CWF section title.
    required String name,

    /// Full text used for keyword go/no-go scanning.
    required String detailedForecast,
  }) = _MarinePeriod;

  /// Parses a marine period from JSON.
  factory MarinePeriod.fromJson(Map<String, dynamic> json) =>
      _$MarinePeriodFromJson(json);
}

/// Marine forecast summary for a zone (legacy JSON or CWF extract).
@freezed
abstract class MarineSummary with _$MarineSummary {
  /// Creates marine summary for one zone.
  const factory MarineSummary({
    /// NWS marine zone id (e.g. PZZ210).
    required String zoneId,

    /// One or more forecast periods for display and rules.
    required List<MarinePeriod> periods,
  }) = _MarineSummary;

  /// Parses marine summary from JSON.
  factory MarineSummary.fromJson(Map<String, dynamic> json) =>
      _$MarineSummaryFromJson(json);
}

/// Latest USGS instantaneous discharge reading for a site.
@freezed
abstract class RiverFlowReading with _$RiverFlowReading {
  /// Creates a river flow snapshot.
  const factory RiverFlowReading({
    /// USGS site id (parameter 00060).
    required String siteId,

    /// Discharge in cubic feet per second.
    required double cfs,

    /// Observation timestamp from USGS IV JSON.
    required DateTime observedAt,
  }) = _RiverFlowReading;

  /// Parses river flow reading from JSON.
  factory RiverFlowReading.fromJson(Map<String, dynamic> json) =>
      _$RiverFlowReadingFromJson(json);
}

/// Aggregated conditions for one launch (partial success allowed).
@freezed
abstract class ConditionsSnapshot with _$ConditionsSnapshot {
  /// Creates a full conditions fetch result for one launch.
  const factory ConditionsSnapshot({
    /// When this snapshot was assembled on device.
    required DateTime fetchedAt,

    /// Parsed weather, if the weather pipeline succeeded.
    WeatherConditions? weather,

    /// User-facing weather error when [weather] is null.
    String? weatherError,

    /// Parsed tides when the launch uses a NOAA station.
    TideSummary? tides,

    /// User-facing tide error when tides were expected but failed.
    String? tideError,

    /// Parsed marine summary when a marine zone is configured.
    MarineSummary? marine,

    /// User-facing marine error when a zone was configured but failed.
    String? marineError,

    /// Parsed USGS discharge when a site id is configured.
    RiverFlowReading? riverFlow,

    /// User-facing river error when USGS was expected but failed.
    String? riverError,
  }) = _ConditionsSnapshot;

  /// Parses a full conditions snapshot from JSON.
  factory ConditionsSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ConditionsSnapshotFromJson(json);
}
