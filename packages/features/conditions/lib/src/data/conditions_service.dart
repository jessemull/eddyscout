import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/app_failure_mapper.dart';
import 'package:eddyscout_conditions/src/data/parsing/noaa_tides_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/nws_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/nws_marine_cwf.dart';
import 'package:eddyscout_conditions/src/data/parsing/nws_marine_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/open_meteo_json.dart';
import 'package:eddyscout_conditions/src/data/parsing/usgs_iv_json.dart';
import 'package:eddyscout_conditions/src/domain/conditions_load_exception.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';

const _weatherFallbackNoDataCode = 'weather_fallback_no_data';
const _weatherNwsPointsFailedCode = 'weather_nws_points_failed';
const _weatherNwsHourlyUrlMissingCode = 'weather_nws_hourly_url_missing';
const _weatherNwsHourlyFailedCode = 'weather_nws_hourly_failed';
const _weatherNwsHourlyParseFailedCode = 'weather_nws_hourly_parse_failed';
const _weatherNwsErrorCode = 'weather_nws_error';
const _tidesNoPredictionsCode = 'tides_no_predictions';
const _tidesErrorCode = 'tides_error';
const _marineZoneLookupFailedCode = 'marine_zone_lookup_failed';
const _marineNoOfficeLinkedCode = 'marine_no_office_linked';
const _marineOfficeListUnavailableCode = 'marine_office_list_unavailable';
const _marineNoProductsForOfficeCode = 'marine_no_products_for_office';
const _marineProductLoadFailedCode = 'marine_product_load_failed';
const _marineProductNoTextCode = 'marine_product_no_text';
const _marineZoneMissingInProductCode = 'marine_zone_missing_in_product';
const _marineErrorCode = 'marine_error';
const _riverRequestFailedCode = 'river_request_failed';
const _riverUnexpectedResponseCode = 'river_unexpected_response';
const _riverNoDischargeNowCode = 'river_no_discharge_now';
const _riverErrorCode = 'river_error';

/// Fetches NOAA/NWS/Open-Meteo/USGS data per launch metadata (no backend).
class ConditionsService implements ConditionsRepository {
  /// Creates a service that uses the given HTTP client for upstream API calls.
  ConditionsService(this._http);

  final EddyScoutHttpClient _http;

  @override
  FutureResult<ConditionsSnapshot, AppFailure> load(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  }) async {
    try {
      final snapshot = await _loadSnapshot(launch, cancelToken: cancelToken);
      return Result.success(snapshot);
    } on Object catch (e, st) {
      return Result.failure(mapToAppFailure(e, st));
    }
  }

  /// Loads weather, tides, marine, and river flow for one [launch].
  ///
  /// Prefer [load] for package boundaries; this unwraps success or rethrows
  /// [AppFailure] for legacy call sites.
  Future<ConditionsSnapshot> loadSnapshot(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  }) async {
    final result = await load(launch, cancelToken: cancelToken);
    return result.when(
      success: (value) => value,
      failure: (error) => throw ConditionsLoadException(error),
    );
  }

  Future<ConditionsSnapshot> _loadSnapshot(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  }) async {
    final fetchedAt = DateTime.now();

    final weatherFuture = _loadWeather(
      launch.latitude,
      launch.longitude,
      fetchedAt,
      cancelToken: cancelToken,
    );
    final tideFuture = _loadTides(launch, cancelToken: cancelToken);
    final marineFuture = _loadMarine(launch, cancelToken: cancelToken);
    final riverFuture = _loadRiverFlow(launch, cancelToken: cancelToken);

    final results = await Future.wait([
      weatherFuture,
      tideFuture,
      marineFuture,
      riverFuture,
    ]);

    final w = results[0] as _WeatherResult;
    final t = results[1] as _TideResult;
    final m = results[2] as _MarineResult;
    final r = results[3] as _RiverResult;

    return ConditionsSnapshot(
      fetchedAt: fetchedAt,
      weather: w.weather,
      weatherError: w.error,
      tides: t.tides,
      tideError: t.error,
      marine: m.marine,
      marineError: m.error,
      riverFlow: r.flow,
      riverError: r.error,
    );
  }

  Future<_WeatherResult> _loadWeather(
    double lat,
    double lon,
    DateTime now, {
    CancelToken? cancelToken,
  }) async {
    Future<_WeatherResult> openMeteoOrError(String code) async {
      final w = await _openMeteoWeather(lat, lon, cancelToken: cancelToken);
      if (w != null) return _WeatherResult(w, null);
      return _WeatherResult(null, code);
    }

    try {
      final pointsUri = Uri.parse(
        'https://api.weather.gov/points/${lat.toStringAsFixed(4)},'
        '${lon.toStringAsFixed(4)}',
      );
      final pointsJson = await _http.getNwsJson(
        pointsUri,
        cancelToken: cancelToken,
      );
      if (pointsJson == null) {
        return openMeteoOrError(_weatherNwsPointsFailedCode);
      }
      final hourlyUri = nwsHourlyForecastUriFromPoints(pointsJson);
      if (hourlyUri == null) {
        return openMeteoOrError(_weatherNwsHourlyUrlMissingCode);
      }
      final hourlyJson = await _http.getNwsJson(
        hourlyUri,
        cancelToken: cancelToken,
      );
      if (hourlyJson == null) {
        return openMeteoOrError(_weatherNwsHourlyFailedCode);
      }
      final parsed = weatherFromNwsHourly(hourlyJson, now: now);
      if (parsed == null) {
        return openMeteoOrError(_weatherNwsHourlyParseFailedCode);
      }
      return _WeatherResult(parsed, null);
    } on Exception catch (_) {
      try {
        return await openMeteoOrError(_weatherNwsErrorCode);
      } on Exception catch (_) {
        // Preserve exception boundaries without leaking technical details
        // to user-visible strings.
        return _WeatherResult(null, _weatherFallbackNoDataCode);
      }
    }
  }

  Future<WeatherConditions?> _openMeteoWeather(
    double lat,
    double lon, {
    CancelToken? cancelToken,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toStringAsFixed(5),
      'longitude': lon.toStringAsFixed(5),
      'current': [
        'temperature_2m',
        'wind_speed_10m',
        'wind_gusts_10m',
        'wind_direction_10m',
      ].join(','),
      'temperature_unit': 'fahrenheit',
      'wind_speed_unit': 'mph',
    });
    final json = await _http.getJson(uri, cancelToken: cancelToken);
    if (json == null) return null;
    return weatherFromOpenMeteoCurrent(json);
  }

  Future<_TideResult> _loadTides(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  }) async {
    if (launch.tideRelevance == TideRelevance.none ||
        launch.noaaTideStationId == null) {
      return _TideResult(null, null);
    }
    final station = launch.noaaTideStationId!;
    final start = DateTime.now();
    final end = start.add(const Duration(days: 2));
    String ymd(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}'
        '${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}';

    Future<TideSummary?> tryDatum(String datum) async {
      final uri = Uri.https(
        'api.tidesandcurrents.noaa.gov',
        '/api/prod/datagetter',
        {
          'product': 'predictions',
          'application': 'EddyScout',
          'begin_date': ymd(start),
          'end_date': ymd(end),
          'datum': datum,
          'station': station,
          'time_zone': 'lst_ldt',
          'units': 'english',
          'interval': 'hilo',
          'format': 'json',
        },
      );
      final res = await _http.get(uri, cancelToken: cancelToken);
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final map = jsonDecode(res.body);
      if (map is! Map<String, dynamic>) return null;
      if (map.containsKey('error')) return null;
      return tidesFromNoaaPredictions(
        map,
        stationId: station,
        datumLabel: datum,
      );
    }

    try {
      final crd = await tryDatum('CRD');
      if (crd != null) return _TideResult(crd, null);
      final mllw = await tryDatum('MLLW');
      if (mllw != null) return _TideResult(mllw, null);
      return _TideResult(null, _tidesNoPredictionsCode);
    } on Exception catch (_) {
      return _TideResult(null, _tidesErrorCode);
    }
  }

  Future<_MarineResult> _loadMarine(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  }) async {
    final zone = launch.marineZoneId;
    if (zone == null || zone.isEmpty) return _MarineResult(null, null);
    try {
      // NWS returns 404 "Marine Forecast Not Supported" for
      // /zones/marine/{id}/forecast — use CWF text instead.
      final legacyUri = Uri.parse(
        'https://api.weather.gov/zones/marine/$zone/forecast',
      );
      final legacyJson = await _http.getNwsJson(
        legacyUri,
        cancelToken: cancelToken,
      );
      if (legacyJson != null) {
        final m = marineFromNwsZoneForecast(legacyJson, zoneId: zone);
        if (m != null) return _MarineResult(m, null);
      }
      return _loadMarineFromCwf(zone, cancelToken: cancelToken);
    } on Exception catch (_) {
      return _MarineResult(null, _marineErrorCode);
    }
  }

  Future<_MarineResult> _loadMarineFromCwf(
    String zone, {
    CancelToken? cancelToken,
  }) async {
    final zoneUri = Uri.parse('https://api.weather.gov/zones/marine/$zone');
    final zoneJson = await _http.getNwsJson(
      zoneUri,
      cancelToken: cancelToken,
    );
    if (zoneJson == null) {
      return _MarineResult(null, _marineZoneLookupFailedCode);
    }
    final office = nwsMarineZoneCwaOffice(zoneJson);
    if (office == null || office.isEmpty) {
      return _MarineResult(null, _marineNoOfficeLinkedCode);
    }

    final listUri = Uri.parse(
      'https://api.weather.gov/products/types/CWF/locations/$office',
    );
    final listJson = await _http.getNwsJson(
      listUri,
      cancelToken: cancelToken,
    );
    if (listJson == null) {
      return _MarineResult(null, _marineOfficeListUnavailableCode);
    }
    final productId = nwsLatestCwfProductId(listJson);
    if (productId == null) {
      return _MarineResult(null, _marineNoProductsForOfficeCode);
    }

    final productUri = Uri.parse('https://api.weather.gov/products/$productId');
    final productJson = await _http.getNwsJson(
      productUri,
      cancelToken: cancelToken,
    );
    if (productJson == null) {
      return _MarineResult(null, _marineProductLoadFailedCode);
    }
    final text = productJson['productText'];
    if (text is! String || text.isEmpty) {
      return _MarineResult(null, _marineProductNoTextCode);
    }
    final summary = marineSummaryFromCwfProductText(text, zone);
    if (summary == null) {
      return _MarineResult(null, _marineZoneMissingInProductCode);
    }
    return _MarineResult(summary, null);
  }

  Future<_RiverResult> _loadRiverFlow(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  }) async {
    final site = launch.usgsSiteId;
    if (site == null) return _RiverResult(null, null);
    try {
      final uri = Uri.https('waterservices.usgs.gov', '/nwis/iv/', {
        'format': 'json',
        'sites': site,
        'parameterCd': '00060',
        'siteStatus': 'active',
      });
      final res = await _http.get(uri, cancelToken: cancelToken);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return _RiverResult(null, _riverRequestFailedCode);
      }
      final map = jsonDecode(res.body);
      if (map is! Map<String, dynamic>) {
        return _RiverResult(null, _riverUnexpectedResponseCode);
      }
      final reading = riverFlowFromUsgsIv(map, siteId: site);
      return _RiverResult(
        reading,
        reading == null ? _riverNoDischargeNowCode : null,
      );
    } on Exception catch (_) {
      return _RiverResult(null, _riverErrorCode);
    }
  }
}

class _WeatherResult {
  _WeatherResult(this.weather, this.error);
  final WeatherConditions? weather;
  final String? error;
}

class _TideResult {
  _TideResult(this.tides, this.error);
  final TideSummary? tides;
  final String? error;
}

class _MarineResult {
  _MarineResult(this.marine, this.error);
  final MarineSummary? marine;
  final String? error;
}

class _RiverResult {
  _RiverResult(this.flow, this.error);
  final RiverFlowReading? flow;
  final String? error;
}
