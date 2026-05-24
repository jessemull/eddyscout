import '../conditions_models.dart';

RiverFlowReading? riverFlowFromUsgsIv(
  Map<String, dynamic> json, {
  required String siteId,
}) {
  final list = json['value']?['timeSeries'];
  if (list is! List<dynamic> || list.isEmpty) return null;
  final first = list.first;
  if (first is! Map<String, dynamic>) return null;
  final values = first['values'];
  if (values is! List<dynamic> || values.isEmpty) return null;
  final block = values.first;
  if (block is! Map<String, dynamic>) return null;
  final inner = block['value'];
  if (inner is! List<dynamic> || inner.isEmpty) return null;
  final last = inner.last;
  if (last is! Map<String, dynamic>) return null;
  final v = last['value'] as String?;
  final dt = last['dateTime'] as String?;
  if (v == null || dt == null) return null;
  final cfs = double.tryParse(v);
  if (cfs == null) return null;
  final observed = DateTime.tryParse(dt);
  if (observed == null) return null;
  return RiverFlowReading(siteId: siteId, cfs: cfs, observedAt: observed);
}
