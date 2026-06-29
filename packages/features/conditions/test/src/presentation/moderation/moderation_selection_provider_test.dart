import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ModerationSelection toggles, selects all, clears, and retains', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(moderationSelectionProvider.notifier);

    notifier
      ..toggle('a')
      ..toggle('b')
      ..toggle('a');
    expect(container.read(moderationSelectionProvider), {'b'});

    notifier.selectAll(['x', 'y', 'z']);
    expect(container.read(moderationSelectionProvider), {'x', 'y', 'z'});

    notifier.retainOnly(['y', 'z', 'missing']);
    expect(container.read(moderationSelectionProvider), {'y', 'z'});

    notifier.clear();
    expect(container.read(moderationSelectionProvider), isEmpty);
  });
}
