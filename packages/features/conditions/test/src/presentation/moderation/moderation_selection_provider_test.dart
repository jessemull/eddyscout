import 'package:eddyscout_conditions/src/presentation/moderation/moderation_selection_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggle adds and removes report ids', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(moderationSelectionProvider.notifier);
    expect(container.read(moderationSelectionProvider), isEmpty);

    notifier.toggle('a');
    expect(container.read(moderationSelectionProvider), {'a'});

    notifier.toggle('a');
    expect(container.read(moderationSelectionProvider), isEmpty);
  });

  test('selectAll replaces selection', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(moderationSelectionProvider.notifier);
    notifier.toggle('old');
    notifier.selectAll(['a', 'b']);

    expect(container.read(moderationSelectionProvider), {'a', 'b'});
  });

  test('clear empties selection', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(moderationSelectionProvider.notifier);
    notifier.selectAll(['a']);
    notifier.clear();

    expect(container.read(moderationSelectionProvider), isEmpty);
  });

  test('retainOnly keeps visible ids', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(moderationSelectionProvider.notifier);
    notifier.selectAll(['a', 'b', 'c']);
    notifier.retainOnly(['b', 'c', 'd']);

    expect(container.read(moderationSelectionProvider), {'b', 'c'});
  });
}
