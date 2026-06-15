import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/map_trip_duration.dart';
import 'map_key_value_store_provider.dart';

part 'paddle_speed_provider.g.dart';

/// SharedPreferences key for the user's paddling speed (km/h).
const String kPaddleSpeedKmhKey = 'paddle_speed_kmh';

/// Minimum selectable paddling speed for trip-time estimates (km/h).
const double kMinPaddleSpeedKmh = 1;

/// Maximum selectable paddling speed for trip-time estimates (km/h).
const double kMaxPaddleSpeedKmh = 10;

/// Slider step size for paddling speed (km/h).
const double kPaddleSpeedStepKmh = 0.5;

/// Number of slider divisions between [kMinPaddleSpeedKmh] and
/// [kMaxPaddleSpeedKmh].
const int kPaddleSpeedSliderDivisions = 18;

/// User's average paddling speed for trip-time estimates.
@Riverpod(keepAlive: true)
class PaddleSpeed extends _$PaddleSpeed {
  @override
  Future<double> build() async {
    final store = await ref.watch(mapKeyValueStoreProvider.future);
    final stored = await store.getDouble(kPaddleSpeedKmhKey);
    return normalizePaddleSpeedKmh(stored ?? kDefaultKayakSpeedKmh);
  }

  /// Persists [speedKmh] and updates provider state.
  Future<void> setSpeed(double speedKmh) async {
    final normalized = normalizePaddleSpeedKmh(speedKmh);
    final store = await ref.read(mapKeyValueStoreProvider.future);
    await store.setDouble(kPaddleSpeedKmhKey, normalized);
    state = AsyncData(normalized);
  }

  /// Clears the stored preference and restores [kDefaultKayakSpeedKmh].
  Future<void> resetToDefault() async {
    final store = await ref.read(mapKeyValueStoreProvider.future);
    await store.remove(kPaddleSpeedKmhKey);
    state = const AsyncData(kDefaultKayakSpeedKmh);
  }
}

/// Current paddling speed for trip estimates, falling back to the default.
@Riverpod(keepAlive: true)
double effectivePaddleSpeedKmh(Ref ref) {
  final asyncSpeed = ref.watch(paddleSpeedProvider);
  return asyncSpeed.whenOrNull(data: (value) => value) ?? kDefaultKayakSpeedKmh;
}

/// Clamps and snaps [speedKmh] to the supported slider range and step.
double normalizePaddleSpeedKmh(double speedKmh) {
  final clamped = speedKmh.clamp(kMinPaddleSpeedKmh, kMaxPaddleSpeedKmh);
  final steps = ((clamped - kMinPaddleSpeedKmh) / kPaddleSpeedStepKmh).round();
  return kMinPaddleSpeedKmh + (steps * kPaddleSpeedStepKmh);
}
