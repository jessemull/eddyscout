import 'package:shared_preferences/shared_preferences.dart';

import '../decision/go_no_go.dart';

const _key = 'go_no_go_profile';

/// Persists [GoNoGoProfile] for wind tier scaling in [GoNoGoEvaluator].
class GoNoGoProfilePrefs {
  GoNoGoProfilePrefs._();

  static Future<GoNoGoProfile> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    return _parse(raw) ?? GoNoGoProfile.intermediate;
  }

  static Future<void> save(GoNoGoProfile profile) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, profile.name);
  }

  static GoNoGoProfile? _parse(String? raw) {
    if (raw == null) return null;
    for (final e in GoNoGoProfile.values) {
      if (e.name == raw) return e;
    }
    return null;
  }
}
