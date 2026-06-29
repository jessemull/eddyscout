import 'dart:convert';
import 'dart:io';

import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/src/data/parsing/noaa_tides_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/nws_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/nws_marine_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/open_meteo_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/usgs_iv_json.dart';
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
    final r = riverFlowFromUsgsIv(_fixture('usgs_iv.json'), siteId: '14211720');
    expect(r, isNotNull);
    expect(r!.cfs, 11000);
    expect(r.siteId, '14211720');
  });

  test('riverFlowFromUsgsIv rejects non-positive cfs', () {
    final json = Map<String, dynamic>.from(_fixture('usgs_iv.json'));
    final values =
        (json['value'] as Map<String, dynamic>)['timeSeries'] as List<dynamic>;
    final block =
        (values.first as Map<String, dynamic>)['values'] as List<dynamic>;
    final inner =
        (block.first as Map<String, dynamic>)['value'] as List<dynamic>;
    (inner.last as Map<String, dynamic>)['value'] = '-15800';

    expect(riverFlowFromUsgsIv(json, siteId: '14211720'), isNull);
  });

  test('riverFlowFromUsgsIv rejects zero cfs', () {
    final json = Map<String, dynamic>.from(_fixture('usgs_iv.json'));
    final values =
        (json['value'] as Map<String, dynamic>)['timeSeries'] as List<dynamic>;
    final block =
        (values.first as Map<String, dynamic>)['values'] as List<dynamic>;
    final inner =
        (block.first as Map<String, dynamic>)['value'] as List<dynamic>;
    (inner.last as Map<String, dynamic>)['value'] = '0';

    expect(riverFlowFromUsgsIv(json, siteId: '14211720'), isNull);
  });

  test('rawCfsStringFromUsgsIv reads latest cfs string', () {
    expect(
      rawCfsStringFromUsgsIv(_fixture('usgs_iv.json')),
      '11000',
    );
  });

  test('rawCfsStringFromUsgsIv returns null for malformed payload', () {
    expect(rawCfsStringFromUsgsIv(const {}), isNull);
  });

  test(
    'tidesFromNoaaPredictions skips malformed rows and parses local time',
    () {
      final summary = tidesFromNoaaPredictions(
        {
          'predictions': [
            {'t': '2026-04-12 02:34', 'v': '2.1', 'type': 'H'},
            {'t': 'bad-time', 'v': '1.0', 'type': 'L'},
            'not-a-map',
          ],
        },
        stationId: '9439221',
        datumLabel: 'MLLW',
        referenceNote: 'note',
      );

      expect(summary, isNotNull);
      expect(summary!.events, hasLength(1));
      expect(summary.events.first.type, 'H');
      expect(summary.referenceNote, 'note');
    },
  );

  test('tidesFromNoaaPredictions returns null when predictions missing', () {
    expect(
      tidesFromNoaaPredictions(const {}, stationId: 's', datumLabel: 'MLLW'),
      isNull,
    );
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
