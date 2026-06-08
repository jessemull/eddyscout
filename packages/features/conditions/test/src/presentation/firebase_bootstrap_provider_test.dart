import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseBootstrapState', () {
    test('hintForError returns null when no user-facing error', () {
      const state = FirebaseBootstrapState();
      expect(state.hintForError(), isNull);
    });

    test('hintForError returns guidance for admin-restricted-operation', () {
      const state = FirebaseBootstrapState(
        userFacingError: 'admin-restricted-operation',
      );
      expect(state.hintForError(), contains('Anonymous'));
    });

    test('hintForError returns guidance for operation-not-allowed', () {
      const state = FirebaseBootstrapState(
        userFacingError: 'operation-not-allowed',
      );
      expect(state.hintForError(), contains('Firebase Console'));
    });
  });

  group('firebaseBootstrapUserFacingError', () {
    test('maps admin-restricted-operation to user-safe message', () {
      expect(
        firebaseBootstrapUserFacingError(
          Exception('admin-restricted-operation'),
        ),
        'Anonymous sign-in is disabled in Firebase Console.',
      );
    });

    test('maps unknown errors to generic initialization message', () {
      expect(
        firebaseBootstrapUserFacingError(Exception('network down')),
        contains('Firebase could not be initialized'),
      );
    });
  });

  test('firebaseBootstrapProvider defaults to idle state', () {
    expect(const FirebaseBootstrapState(), const FirebaseBootstrapState());
  });
}
