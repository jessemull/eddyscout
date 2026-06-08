import 'dart:async' show unawaited;

import 'package:eddyscout/routing/app_shell.dart';
import 'package:eddyscout/routing/map_save_route_sheet.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

const _integrationMapStub = bool.fromEnvironment('INTEGRATION_MAP_STUB');

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<MapShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<MapRoute>(path: RoutePaths.map),
        TypedGoRoute<LaunchDetailRoute>(path: RoutePaths.launchDetail),
      ],
    ),
    TypedStatefulShellBranch<SavedRoutesShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SavedRoutesListRoute>(path: RoutePaths.savedRoutes),
        TypedGoRoute<SavedRouteDetailRoute>(path: RoutePaths.savedRouteDetail),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
}

class MapShellBranchData extends StatefulShellBranchData {
  const MapShellBranchData();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'mapShell');
}

class SavedRoutesShellBranchData extends StatefulShellBranchData {
  const SavedRoutesShellBranchData();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'savedRoutesShell');
}

@TypedGoRoute<MapRoute>(path: RoutePaths.map)
class MapRoute extends GoRouteData with $MapRoute {
  const MapRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const _MapRouteHost();
}

class _MapRouteHost extends ConsumerWidget {
  const _MapRouteHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..listen(pendingSavedRouteLoadProvider, (previous, next) {
        if (next != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }
            unawaited(handlePendingSavedRouteLoad(context, ref));
          });
        }
      })
      ..listen(mapTabResumedProvider, (previous, next) {
        if (next == 0) {
          return;
        }
        final planning = ref.read(routePlanningProvider);
        final polyline = planning.polylineLonLat;
        if (planning.planningMode && polyline != null && polyline.length >= 2) {
          unawaited(
            ref
                .read(mapboxMapControllerProvider.notifier)
                .displayPlannedRoute(polyline),
          );
        }
      });

    void onOpenLaunchDetail(LaunchPoint launch) {
      unawaited(LaunchDetailRoute(launchId: launch.id).push<void>(context));
    }

    if (_integrationMapStub) {
      return MapScreen(
        mapSlot: const SizedBox(key: Key('integration_map_stub')),
        onOpenLaunchDetail: onOpenLaunchDetail,
        onSaveRoute: () => unawaited(showMapSaveRouteSheet(context, ref)),
      );
    }
    return MapScreen(
      onOpenLaunchDetail: onOpenLaunchDetail,
      onSaveRoute: () => unawaited(showMapSaveRouteSheet(context, ref)),
    );
  }
}

@TypedGoRoute<LaunchDetailRoute>(path: RoutePaths.launchDetail)
class LaunchDetailRoute extends GoRouteData with $LaunchDetailRoute {
  const LaunchDetailRoute({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      _LaunchDetailRouteBody(launchId: launchId);
}

@TypedGoRoute<SavedRoutesListRoute>(path: RoutePaths.savedRoutes)
class SavedRoutesListRoute extends GoRouteData with $SavedRoutesListRoute {
  const SavedRoutesListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SavedRoutesListScreen(
        onOpenRouteDetail: (routeId) {
          unawaited(
            SavedRouteDetailRoute(routeId: routeId).push<void>(context),
          );
        },
      );
}

@TypedGoRoute<SavedRouteDetailRoute>(path: RoutePaths.savedRouteDetail)
class SavedRouteDetailRoute extends GoRouteData with $SavedRouteDetailRoute {
  const SavedRouteDetailRoute({required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      _SavedRouteDetailRouteBody(routeId: routeId);
}

class _SavedRouteDetailRouteBody extends ConsumerWidget {
  const _SavedRouteDetailRouteBody({required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SavedRouteDetailScreen(
    routeId: routeId,
    onLoadOnMap: (route) => _loadSavedRouteOnMap(context, ref, route),
  );
}

void _loadSavedRouteOnMap(
  BuildContext context,
  WidgetRef ref,
  SavedRoute route,
) {
  ref.read(pendingSavedRouteLoadProvider.notifier).draftRoute = route;
  unawaited(
    ref
        .read(analyticsClientProvider)
        .logEvent(
          const AnalyticsEvent(name: AnalyticsEvents.savedRouteLoadOnMap),
        ),
  );
  const MapRoute().go(context);
  StatefulNavigationShell.maybeOf(context)?.goBranch(0);
}

class _LaunchDetailRouteBody extends ConsumerWidget {
  const _LaunchDetailRouteBody({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launch = ref.readLaunchPointIfExists(launchId);
    if (launch == null) {
      return const _LaunchNotFoundBody();
    }
    return LaunchDetailScreen(launch: launch);
  }
}

@TypedGoRoute<MissingMapboxTokenRoute>(path: RoutePaths.missingToken)
class MissingMapboxTokenRoute extends GoRouteData
    with $MissingMapboxTokenRoute {
  const MissingMapboxTokenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MissingMapboxTokenScreen();
}

@TypedGoRoute<WebMapPlaceholderRoute>(path: RoutePaths.web)
class WebMapPlaceholderRoute extends GoRouteData with $WebMapPlaceholderRoute {
  const WebMapPlaceholderRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WebMapPlaceholderScreen();
}

/// Fallback when a deep link references an unknown launch id.
class _LaunchNotFoundBody extends StatelessWidget {
  const _LaunchNotFoundBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.launchNotFoundTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.launchNotFoundBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
