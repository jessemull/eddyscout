import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateSavedRouteId', () {
    test('returns unique ids with sr_ prefix', () {
      final first = generateSavedRouteId();
      final second = generateSavedRouteId();

      expect(first, startsWith('sr_'));
      expect(second, startsWith('sr_'));
      expect(first, isNot(equals(second)));
    });
  });
}
