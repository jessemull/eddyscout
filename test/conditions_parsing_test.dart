import 'dart:convert';
import 'dart:io';

import 'package:eddyscout/conditions/conditions_models.dart';
import 'package:eddyscout/conditions/parsing/noaa_tides_json.dart';
import 'package:eddyscout/conditions/parsing/nws_json.dart';
import 'package:eddyscout/conditions/parsing/nws_marine_json.dart';
import 'package:eddyscout/conditions/parsing/open_meteo_json.dart';
import 'package:eddyscout/conditions/parsing/usgs_iv_json.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixture(String name) {
  final path = '${Directory.current.path}/test/fixtures/$name';
  final raw = File(path).readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  test('nwsHourlyForecastUriFromPoints extracts URL', () {
    final uri = nwsHourlyForecastUriFromPoints(_fixture('nws_points.json'));
    expect(
      uri?.toString(),
      'https://api.weather.gov/gridpoints/PQR/112,131/forecast/hourly',
    );
  });

  test('weatherFromNwsHourly parses wind range and temperature', () {
    final w = weatherFromNwsHourly(
      _fixture('nws_hourly.json'),
      now: DateTime.parse('2026-04-12T15:00:00-07:00'),
    );
    expect(w, isNotNull);
    expect(w!.temperatureF, 58);
    expect(w.windSpeedMph, 12);
    expect(w.windDirection, 'NW');
    expect(w.source, WeatherDataSource.nws);
  });

  test('weatherFromOpenMeteoCurrent parses model fields', () {
    final w = weatherFromOpenMeteoCurrent(_fixture('open_meteo_current.json'));
    expect(w, isNotNull);
    expect(w!.temperatureF, 61);
    expect(w.windSpeedMph, 7);
    expect(w.windGustMph, 14);
    expect(w.windDirection, 'W');
    expect(w.source, WeatherDataSource.openMeteo);
  });

  test('tidesFromNoaaPredictions parses local times', () {
    final t = tidesFromNoaaPredictions(
      _fixture('noaa_predictions.json'),
      stationId: '9439221',
      datumLabel: 'MLLW',
    );
    expect(t, isNotNull);
    expect(t!.events.length, 2);
    expect(t.events.first.type, 'H');
    expect(t.events.first.heightFt, closeTo(2.155, 0.001));
  });

  test('riverFlowFromUsgsIv reads latest cfs', () {
    final r = riverFlowFromUsgsIv(
      _fixture('usgs_iv.json'),
      siteId: '14211720',
    );
    expect(r, isNotNull);
    expect(r!.cfs, 11000);
    expect(r.siteId, '14211720');
  });

  test('marineFromNwsZoneForecast collects periods', () {
    final m = marineFromNwsZoneForecast(
      _fixture('nws_marine.json'),
      zoneId: 'PZZ210',
    );
    expect(m, isNotNull);
    expect(m!.periods.length, 2);
    expect(m.zoneId, 'PZZ210');
  });
}
