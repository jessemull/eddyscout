/// Which API supplied the weather card.
enum WeatherDataSource { nws, openMeteo }

extension WeatherDataSourceLabel on WeatherDataSource {
  String get displayName => switch (this) {
    WeatherDataSource.nws => 'National Weather Service',
    WeatherDataSource.openMeteo => 'Open-Meteo',
  };
}

class WeatherConditions {
  const WeatherConditions({
    required this.temperatureF,
    required this.windSpeedMph,
    this.windGustMph,
    this.windDirection,
    this.shortForecast,
    required this.periodStart,
    required this.source,
  });

  final int? temperatureF;
  final int? windSpeedMph;
  final int? windGustMph;
  final String? windDirection;
  final String? shortForecast;
  final DateTime? periodStart;
  final WeatherDataSource source;
}

class TideEvent {
  const TideEvent({
    required this.type,
    required this.heightFt,
    required this.time,
  });

  final String type;
  final double? heightFt;
  final DateTime time;
}

class TideSummary {
  const TideSummary({
    required this.stationId,
    required this.datumLabel,
    required this.events,
    this.referenceNote,
  });

  final String stationId;
  final String datumLabel;
  final List<TideEvent> events;
  final String? referenceNote;
}

class MarinePeriod {
  const MarinePeriod({required this.name, required this.detailedForecast});

  final String name;
  final String detailedForecast;
}

class MarineSummary {
  const MarineSummary({required this.zoneId, required this.periods});

  final String zoneId;
  final List<MarinePeriod> periods;
}

class RiverFlowReading {
  const RiverFlowReading({
    required this.siteId,
    required this.cfs,
    required this.observedAt,
  });

  final String siteId;
  final double cfs;
  final DateTime observedAt;
}

/// Aggregated conditions for one launch (partial success allowed).
class ConditionsSnapshot {
  const ConditionsSnapshot({
    required this.fetchedAt,
    this.weather,
    this.weatherError,
    this.tides,
    this.tideError,
    this.marine,
    this.marineError,
    this.riverFlow,
    this.riverError,
  });

  final DateTime fetchedAt;
  final WeatherConditions? weather;
  final String? weatherError;
  final TideSummary? tides;
  final String? tideError;
  final MarineSummary? marine;
  final String? marineError;
  final RiverFlowReading? riverFlow;
  final String? riverError;
}
