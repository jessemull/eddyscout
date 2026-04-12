import '../conditions_models.dart';
import 'wind_parse.dart';

/// Extracts hourly forecast URL from `/points/{lat},{lon}` GeoJSON.
Uri? nwsHourlyForecastUriFromPoints(Map<String, dynamic> geoJson) {
  final props = geoJson['properties'];
  if (props is! Map<String, dynamic>) return null;
  final url = props['forecastHourly'];
  if (url is! String || url.isEmpty) return null;
  return Uri.tryParse(url);
}

WeatherConditions? weatherFromNwsHourly(
  Map<String, dynamic> geoJson, {
  required DateTime now,
}) {
  final props = geoJson['properties'];
  if (props is! Map<String, dynamic>) return null;
  final periods = props['periods'];
  if (periods is! List<dynamic> || periods.isEmpty) return null;

  Map<String, dynamic>? pick;
  for (final p in periods) {
    if (p is! Map<String, dynamic>) continue;
    final start = p['startTime'];
    if (start is! String) {
      pick = p;
      break;
    }
    final t = DateTime.tryParse(start);
    if (t != null && !t.isAfter(now.add(const Duration(hours: 1)))) {
      pick = p;
      break;
    }
    pick ??= p;
  }
  if (pick == null) return null;

  final temp = pick['temperature'];
  final wind = pick['windSpeed'] as String?;
  final gustRaw = pick['windGust'] as String?;
  final dir = pick['windDirection'] as String?;
  final short = pick['shortForecast'] as String?;
  final startTime = pick['startTime'] as String?;

  return WeatherConditions(
    temperatureF: temp is num ? temp.round() : int.tryParse('$temp'),
    windSpeedMph: parseWindMph(wind),
    windGustMph: parseWindMph(gustRaw),
    windDirection: dir,
    shortForecast: short,
    periodStart: startTime != null ? DateTime.tryParse(startTime) : null,
    source: WeatherDataSource.nws,
  );
}
