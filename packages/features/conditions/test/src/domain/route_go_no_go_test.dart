import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

RouteWaypointGoNoGoResult _stop({
  required int order,
  required GoNoGoVerdict verdict,
  List<GoNoGoReason> reasons = const [],
}) {
  return RouteWaypointGoNoGoResult(
    orderIndex: order,
    launchId: 'stop_$order',
    launchName: 'Stop $order',
    result: GoNoGoResult(
      verdict: verdict,
      reasons: reasons,
      computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
    ),
  );
}

void main() {
  final computedAt = DateTime.parse('2026-06-15T12:00:00-07:00');

  group('RouteGoNoGoRollup.rollUp', () {
    test('single waypoint returns same verdict', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [_stop(order: 0, verdict: GoNoGoVerdict.marginal)],
        failures: const [],
        computedAt: computedAt,
      );

      expect(result.verdict, GoNoGoVerdict.marginal);
      expect(result.triggeringWaypoint?.orderIndex, 0);
    });

    test('all go → go with no triggering stop', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [
          _stop(order: 0, verdict: GoNoGoVerdict.go),
          _stop(order: 1, verdict: GoNoGoVerdict.go),
        ],
        failures: const [],
        computedAt: computedAt,
      );

      expect(result.verdict, GoNoGoVerdict.go);
      expect(result.triggeringWaypoint, isNull);
      expect(result.triggeringReasons, isEmpty);
    });

    test('all insufficientData → insufficientData', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [
          _stop(order: 0, verdict: GoNoGoVerdict.insufficientData),
          _stop(order: 1, verdict: GoNoGoVerdict.insufficientData),
        ],
        failures: const [],
        computedAt: computedAt,
      );

      expect(result.verdict, GoNoGoVerdict.insufficientData);
      expect(result.triggeringWaypoint?.orderIndex, 0);
    });

    test('marginal beats go and insufficientData in mix', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [
          _stop(order: 0, verdict: GoNoGoVerdict.go),
          _stop(order: 1, verdict: GoNoGoVerdict.insufficientData),
          _stop(order: 2, verdict: GoNoGoVerdict.marginal),
        ],
        failures: const [],
        computedAt: computedAt,
      );

      expect(result.verdict, GoNoGoVerdict.marginal);
      expect(result.triggeringWaypoint?.orderIndex, 2);
    });

    test('noGo beats marginal and insufficientData', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [
          _stop(order: 0, verdict: GoNoGoVerdict.marginal),
          _stop(order: 1, verdict: GoNoGoVerdict.noGo),
          _stop(order: 2, verdict: GoNoGoVerdict.insufficientData),
        ],
        failures: const [],
        computedAt: computedAt,
      );

      expect(result.verdict, GoNoGoVerdict.noGo);
      expect(result.triggeringWaypoint?.orderIndex, 1);
    });

    test('first stop wins tie on same rolled rank', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [
          _stop(order: 0, verdict: GoNoGoVerdict.marginal),
          _stop(order: 1, verdict: GoNoGoVerdict.marginal),
        ],
        failures: const [],
        computedAt: computedAt,
      );

      expect(result.verdict, GoNoGoVerdict.marginal);
      expect(result.triggeringWaypoint?.orderIndex, 0);
    });

    test('triggering reasons exclude info severity', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [
          _stop(
            order: 0,
            verdict: GoNoGoVerdict.marginal,
            reasons: const [
              GoNoGoReason(
                code: GoNoGoReasonCode.coldWaterSeason,
                severity: GoNoGoReasonSeverity.info,
              ),
              GoNoGoReason(
                code: GoNoGoReasonCode.windElevated,
                severity: GoNoGoReasonSeverity.marginal,
                windMph: 16,
                exposure: 'moderate',
              ),
            ],
          ),
        ],
        failures: const [],
        computedAt: computedAt,
      );

      expect(result.triggeringReasons.length, 1);
      expect(
        result.triggeringReasons.first.code,
        GoNoGoReasonCode.windElevated,
      );
    });

    test('empty evaluated throws UnexpectedFailure', () {
      expect(
        () => RouteGoNoGoRollup.rollUp(
          evaluated: const [],
          failures: const [],
          computedAt: computedAt,
        ),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('sorts evaluated stops by order index', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [
          _stop(order: 2, verdict: GoNoGoVerdict.go),
          _stop(order: 0, verdict: GoNoGoVerdict.go),
          _stop(order: 1, verdict: GoNoGoVerdict.go),
        ],
        failures: const [],
        computedAt: computedAt,
      );

      expect(
        result.waypointResults.map((s) => s.orderIndex).toList(),
        [0, 1, 2],
      );
    });

    test('preserves waypoint failures without affecting verdict', () {
      final result = RouteGoNoGoRollup.rollUp(
        evaluated: [_stop(order: 0, verdict: GoNoGoVerdict.go)],
        failures: [
          RouteWaypointGoNoGoFailure(
            orderIndex: 1,
            launchId: 'missing',
            launchName: 'Missing',
            failure: NetworkFailure(message: 'offline'),
          ),
        ],
        computedAt: computedAt,
      );

      expect(result.verdict, GoNoGoVerdict.go);
      expect(result.waypointFailures.length, 1);
    });
  });

  group('RouteGoNoGoRollup.snapStopsOnly', () {
    test('returns insufficientData with empty waypoint results', () {
      final result = RouteGoNoGoRollup.snapStopsOnly(computedAt: computedAt);

      expect(result.verdict, GoNoGoVerdict.insufficientData);
      expect(result.computedAt, computedAt);
      expect(result.waypointResults, isEmpty);
      expect(result.waypointFailures, isEmpty);
      expect(result.triggeringReasons, isEmpty);
    });
  });
}
