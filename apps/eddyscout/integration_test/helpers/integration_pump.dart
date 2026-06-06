import 'package:flutter_test/flutter_test.dart';

/// Pumps a fixed number of frames — safe on Linux CI (no pumpAndSettle).
Future<void> integrationPumpFrames(
  WidgetTester tester, {
  int count = 10,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(step);
  }
}

/// Pumps until [finder] matches or [timeout] elapses.
///
/// Prefer this over pumpAndSettle in integration tests: the Linux desktop
/// embedder often never "settles" (vsync / animations / platform views).
Future<void> integrationWaitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Timed out after $timeout waiting for $finder');
}

/// Bounded settle replacement — pumps frames only, never calls pumpAndSettle.
Future<void> integrationPumpSettle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final frames = timeout.inMilliseconds ~/ step.inMilliseconds;
  await integrationPumpFrames(tester, count: frames, step: step);
}
