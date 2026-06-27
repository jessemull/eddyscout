import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

const _putInTooFarMessage = RoutePlanningFailure(
  code: RouteFailureCode.putInTooFar,
);

final class _RejectingMapRoutePlanner implements MapRoutePlanner {
  const _RejectingMapRoutePlanner();

  @override
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<LaunchPoint> waypoints,
  ) async {
    return const Result.success(null);
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateLaunch(
    LaunchPoint launch,
  ) async {
    return const Result.failure(_putInTooFarMessage);
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateSegment(
    LaunchPoint from,
    LaunchPoint to,
  ) async {
    return const Result.failure(_putInTooFarMessage);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'tryAddPlanningWaypoint shows snackbar and skips waypoint on validateLaunch failure',
    (tester) async {
      final snackbarMessages = <Object>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapRoutePlannerProvider.overrideWith(
              (ref) async => const _RejectingMapRoutePlanner(),
            ),
            mapInteractiveProvider.overrideWithValue(true),
          ],
          child: testLocalizedApp(
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final container = ProviderScope.containerOf(context);
                  container
                      .read(mapboxMapControllerProvider.notifier)
                      .bindUiCallbacks(
                        MapUiCallbacks(
                          pickDifferentTakeOutMessage:
                              'Pick different take-out',
                          riverDataLoadingMessage: 'Loading',
                          riverDataLoadFailedMessage: 'Unavailable',
                          showSnackBar: snackbarMessages.add,
                        ),
                      );
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SizedBox)),
      );
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      container
          .read(mapSheetVisibilityStateProvider.notifier)
          .showPlanningEdit();

      final launch = kLaunchPoints.first;
      final result = await container
          .read(mapboxMapControllerProvider.notifier)
          .tryAddPlanningWaypoint(launch);

      expect(result, isNull);
      expect(container.read(routePlanningProvider).waypoints, isEmpty);
      expect(snackbarMessages, contains(_putInTooFarMessage));
    },
  );

  testWidgets(
    'tryAddPlanningWaypoint shows snackbar and skips waypoint on validateSegment failure',
    (tester) async {
      final snackbarMessages = <Object>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapRoutePlannerProvider.overrideWith(
              (ref) async => const _RejectingMapRoutePlanner(),
            ),
            mapInteractiveProvider.overrideWithValue(true),
          ],
          child: testLocalizedApp(
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final container = ProviderScope.containerOf(context);
                  container
                      .read(mapboxMapControllerProvider.notifier)
                      .bindUiCallbacks(
                        MapUiCallbacks(
                          pickDifferentTakeOutMessage:
                              'Pick different take-out',
                          riverDataLoadingMessage: 'Loading',
                          riverDataLoadFailedMessage: 'Unavailable',
                          showSnackBar: snackbarMessages.add,
                        ),
                      );
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SizedBox)),
      );
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      container
          .read(mapSheetVisibilityStateProvider.notifier)
          .showPlanningEdit();

      final putIn = findLaunchPointById('cathedral_park')!;
      final takeOut = findLaunchPointById('kelley_point')!;
      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);

      final result = await container
          .read(mapboxMapControllerProvider.notifier)
          .tryAddPlanningWaypoint(takeOut);

      expect(result, isNull);
      expect(container.read(routePlanningProvider).waypoints, [putIn]);
      expect(snackbarMessages, contains(_putInTooFarMessage));
    },
  );
}
