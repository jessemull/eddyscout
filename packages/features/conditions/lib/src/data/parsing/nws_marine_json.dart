import 'package:eddyscout_conditions/src/domain/conditions_models.dart';

/// Parses legacy NWS marine zone forecast GeoJSON when the endpoint responds.
MarineSummary? marineFromNwsZoneForecast(
  Map<String, dynamic> geoJson, {
  required String zoneId,
}) {
  final props = geoJson['properties'];
  if (props is! Map<String, dynamic>) return null;
  final periods = props['periods'];
  if (periods is! List<dynamic>) return null;

  final out = <MarinePeriod>[];
  for (final p in periods) {
    if (p is! Map<String, dynamic>) continue;
    final name = p['name'] as String? ?? '';
    final text = p['detailedForecast'] as String? ?? '';
    if (name.isEmpty && text.isEmpty) continue;
    out.add(MarinePeriod(name: name, detailedForecast: text));
  }

  if (out.isEmpty) return null;
  return MarineSummary(zoneId: zoneId, periods: out);
}
