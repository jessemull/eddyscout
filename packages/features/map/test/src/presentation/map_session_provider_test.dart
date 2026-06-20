import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('mapInteractiveProvider', () {
    test('starts non-interactive', () {
      expect(container.read(mapInteractiveProvider), isFalse);
    });

    test('markInteractive and resetInteractive toggle readiness', () {
      container.read(mapInteractiveProvider.notifier).markInteractive();
      expect(container.read(mapInteractiveProvider), isTrue);

      container.read(mapInteractiveProvider.notifier).resetInteractive();
      expect(container.read(mapInteractiveProvider), isFalse);
    });
  });

  group('mapTabResumedProvider', () {
    test('starts at zero and increments on resume', () {
      expect(container.read(mapTabResumedProvider), 0);

      container.read(mapTabResumedProvider.notifier).notifyResumed();
      expect(container.read(mapTabResumedProvider), 1);

      container.read(mapTabResumedProvider.notifier).notifyResumed();
      expect(container.read(mapTabResumedProvider), 2);
    });
  });
}
