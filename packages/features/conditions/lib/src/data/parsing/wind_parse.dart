import 'dart:math';

/// Parses strings like "5 mph", "10 to 15 mph", "Calm" → representative mph.
int? parseWindMph(String? raw) {
  if (raw == null) return null;
  final s = raw.trim().toLowerCase();
  if (s.isEmpty || s == 'calm') return 0;
  final nums = RegExp(r'\d+')
      .allMatches(raw)
      .map((m) => int.tryParse(m.group(0)!))
      .whereType<int>()
      .toList();
  if (nums.isEmpty) return null;
  return nums.reduce(max);
}
