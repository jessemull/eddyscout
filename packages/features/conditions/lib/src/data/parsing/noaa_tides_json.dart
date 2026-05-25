import '../../domain/conditions_models.dart';

/// NOAA returns local river time without offset, e.g. `2026-04-12 02:34`.
DateTime? _parseNoaaLocalDateTime(String t) {
  final iso = t.contains('T') ? t : t.replaceFirst(' ', 'T');
  final parsed = DateTime.tryParse(iso);
  if (parsed != null) return parsed;
  final m = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{1,2}):(\d{2})',
  ).firstMatch(t);
  if (m == null) return null;
  return DateTime(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
    int.parse(m.group(4)!),
    int.parse(m.group(5)!),
  );
}

TideSummary? tidesFromNoaaPredictions(
  Map<String, dynamic> json, {
  required String stationId,
  required String datumLabel,
  String? referenceNote,
}) {
  final preds = json['predictions'];
  if (preds is! List<dynamic>) return null;

  final events = <TideEvent>[];
  for (final p in preds) {
    if (p is! Map<String, dynamic>) continue;
    final t = p['t'] as String?;
    final v = p['v'] as String?;
    final type = p['type'] as String? ?? '';
    if (t == null) continue;
    final time = _parseNoaaLocalDateTime(t);
    if (time == null) continue;
    events.add(
      TideEvent(
        type: type.isEmpty ? '—' : type,
        heightFt: double.tryParse(v ?? ''),
        time: time,
      ),
    );
  }

  if (events.isEmpty) return null;

  return TideSummary(
    stationId: stationId,
    datumLabel: datumLabel,
    events: events,
    referenceNote: referenceNote,
  );
}
