import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapInteractiveProvider starts false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(mapInteractiveProvider), isFalse);
  });

  test('notifyResumed increments map tab resume counter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(mapTabResumedProvider), 0);
    container.read(mapTabResumedProvider.notifier).notifyResumed();
    expect(container.read(mapTabResumedProvider), 1);
  });
}
