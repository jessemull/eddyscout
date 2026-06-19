import 'package:eddyscout_map/src/domain/map_trip_duration.dart';
import 'package:eddyscout_map/src/presentation/map_key_value_store_provider.dart';
import 'package:eddyscout_map/src/presentation/paddle_speed_provider.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('normalizePaddleSpeedKmh', () {
    test('clamps to supported range', () {
      expect(normalizePaddleSpeedKmh(0.5), kMinPaddleSpeedKmh);
      expect(normalizePaddleSpeedKmh(12), kMaxPaddleSpeedKmh);
    });

    test('snaps to nearest half km/h step', () {
      expect(normalizePaddleSpeedKmh(4.2), 4);
      expect(normalizePaddleSpeedKmh(4.3), 4.5);
    });
  });

  group('paddleSpeedProvider', () {
    late MemoryKeyValueStore store;
    late ProviderContainer container;

    setUp(() {
      store = MemoryKeyValueStore();
      container = ProviderContainer(
        overrides: [
          mapKeyValueStoreProvider.overrideWith((ref) async => store),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns default speed when preference is absent', () async {
      final speed = await container.read(paddleSpeedProvider.future);
      expect(speed, kDefaultKayakSpeedKmh);
    });

    test('persists and reloads custom speed', () async {
      await container.read(paddleSpeedProvider.future);
      await container.read(paddleSpeedProvider.notifier).setSpeed(5.5);

      expect(container.read(paddleSpeedProvider).value, 5.5);
      expect(await store.getDouble(kPaddleSpeedKmhKey), 5.5);

      final reloaded = ProviderContainer(
        overrides: [
          mapKeyValueStoreProvider.overrideWith((ref) async => store),
        ],
      );
      addTearDown(reloaded.dispose);

      expect(await reloaded.read(paddleSpeedProvider.future), 5.5);
    });

    test('resetToDefault clears stored preference', () async {
      await container.read(paddleSpeedProvider.future);
      await container.read(paddleSpeedProvider.notifier).setSpeed(6);
      await container.read(paddleSpeedProvider.notifier).resetToDefault();

      expect(container.read(paddleSpeedProvider).value, kDefaultKayakSpeedKmh);
      expect(await store.getDouble(kPaddleSpeedKmhKey), isNull);
    });
  });
}
