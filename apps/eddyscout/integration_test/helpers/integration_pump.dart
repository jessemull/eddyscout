import 'package:flutter_test/flutter_test.dart';

/// Bounded pump-and-settle for integration tests.
///
/// Avoids 10-minute default timeouts on Linux CI when frames never settle.
Future<void> integrationPumpSettle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    timeout,
  );
}
