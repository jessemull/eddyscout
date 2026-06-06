import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapInteractiveProvider starts false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(mapInteractiveProvider), isFalse);
  });

  test('mapInteractiveProvider can be enabled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(mapInteractiveProvider.notifier).markInteractive();

    expect(container.read(mapInteractiveProvider), isTrue);
  });
}
