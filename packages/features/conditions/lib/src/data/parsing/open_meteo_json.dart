import 'package:eddyscout_conditions/src/domain/conditions_models.dart';

/// Parses Open-Meteo `current` block into [WeatherConditions].
WeatherConditions? weatherFromOpenMeteoCurrent(Map<String, dynamic> json) {
  final current = json['current'];
  if (current is! Map<String, dynamic>) return null;

  final temp = current['temperature_2m'];
  final wind = current['wind_speed_10m'];
  final gust = current['wind_gusts_10m'];
  final dirDeg = current['wind_direction_10m'];
  final time = current['time'] as String?;

  String? dirLabel;
  if (dirDeg is num) {
    dirLabel = _compassFromDegrees(dirDeg.toDouble());
  }

  return WeatherConditions(
    temperatureF: temp is num ? temp.round() : null,
    windSpeedMph: wind is num ? wind.round() : null,
    windGustMph: gust is num ? gust.round() : null,
    windDirection: dirLabel,
    periodStart: time != null ? DateTime.tryParse(time) : null,
    source: WeatherDataSource.openMeteo,
  );
}

String _compassFromDegrees(double deg) {
  const dirs = <String>[
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
  ];
  final i = ((deg % 360) / 22.5).round() % 16;
  return dirs[i];
}
