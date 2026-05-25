import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide [SharedPreferences] instance.
///
/// Kept alive for the app lifetime so preference reads are not repeated.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  ref.keepAlive();
  return SharedPreferences.getInstance();
});
