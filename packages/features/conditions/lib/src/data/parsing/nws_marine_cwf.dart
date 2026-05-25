import 'dart:convert';

import 'package:eddyscout_conditions/src/domain/conditions_models.dart';

/// NWS api.weather.gov does not implement `/zones/marine/{id}/forecast` (404).
///
/// Coastal text lives in CWF products per WFO.
///
/// Resolves zone → office, fetches the latest CWF, and extracts the zone block.

/// Reads `properties.cwa[0]` from GET `/zones/marine/{zoneId}` (Feature JSON).
String? nwsMarineZoneCwaOffice(Map<String, dynamic> zoneFeature) {
  final props = zoneFeature['properties'];
  if (props is! Map<String, dynamic>) return null;
  final cwa = props['cwa'];
  if (cwa is! List || cwa.isEmpty) return null;
  final first = cwa.first;
  return first is String ? first : null;
}

/// Picks the newest CWF product id from GET `/products/types/CWF/locations/{office}`.
///
/// The office code is three letters, e.g. `PQR` (same as `cwa` on the zone).
String? nwsLatestCwfProductId(Map<String, dynamic> productsDoc) {
  final graph = productsDoc['@graph'];
  if (graph is! List<dynamic>) return null;
  String? bestId;
  DateTime? bestTime;
  for (final item in graph) {
    if (item is! Map<String, dynamic>) continue;
    final id = item['id'] as String?;
    final t = item['issuanceTime'] as String?;
    if (id == null || t == null) continue;
    final parsed = DateTime.tryParse(t);
    if (parsed == null) continue;
    if (bestTime == null || parsed.isAfter(bestTime)) {
      bestTime = parsed;
      bestId = id;
    }
  }
  return bestId;
}

/// NWS marine zone product headers look like `PZZ210-131115-`.
final _zoneProductHeader = RegExp(r'^([A-Z]{3}\d{3})-\d+-\s*$');

/// Extracts the text block for [zoneId] from raw CWF [productText].
MarineSummary? marineSummaryFromCwfProductText(
  String productText,
  String zoneId,
) {
  final lines = const LineSplitter().convert(productText);
  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final headerMatch = _zoneProductHeader.firstMatch(line);
    if (headerMatch != null && headerMatch.group(1) == zoneId) {
      i++;
      final buf = StringBuffer();
      while (i < lines.length) {
        final l = lines[i];
        if (l.trim() == r'$$') break;
        final nextHeader = _zoneProductHeader.firstMatch(l);
        if (nextHeader != null && nextHeader.group(1) != zoneId) break;
        buf.writeln(l);
        i++;
      }
      final body = buf.toString().trim();
      if (body.isEmpty) return null;
      return MarineSummary(
        zoneId: zoneId,
        periods: [
          MarinePeriod(name: 'Coastal waters forecast', detailedForecast: body),
        ],
      );
    }
    i++;
  }
  return null;
}
