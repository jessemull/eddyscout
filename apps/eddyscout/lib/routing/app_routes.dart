import 'dart:async' show unawaited;

import 'package:eddyscout/routing/app_shell.dart';
import 'package:eddyscout/routing/home_screen.dart';
import 'package:eddyscout/routing/map_save_route_sheet.dart';
import 'package:eddyscout/routing/menu_screen.dart';
import 'package:eddyscout/routing/route_go_no_go_sections.dart';
import 'package:eddyscout/routing/settings_screen.dart';
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
    TypedStatefulShellBranch<HomeShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRoute>(path: RoutePaths.home),
      ],
    ),
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
    TypedStatefulShellBranch<MenuShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<MenuRoute>(path: RoutePaths.menu),
        TypedGoRoute<SettingsRoute>(path: '/settings'),
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

class HomeShellBranchData extends StatefulShellBranchData {
  const HomeShellBranchData();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeShell');
}

class MenuShellBranchData extends StatefulShellBranchData {
  const MenuShellBranchData();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'menuShell');
}

class SavedRoutesShellBranchData extends StatefulShellBranchData {
  const SavedRoutesShellBranchData();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'savedRoutesShell');
}

@TypedGoRoute<HomeRoute>(path: RoutePaths.home)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const _ScreenViewLogger(
        screenName: AnalyticsScreenNames.home,
        child: HomeScreen(),
      );
}

@TypedGoRoute<MenuRoute>(path: RoutePaths.menu)
class MenuRoute extends GoRouteData with $MenuRoute {
  const MenuRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const _ScreenViewLogger(
        screenName: AnalyticsScreenNames.menu,
        child: MenuScreen(),
      );
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsScreen();
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
      ref.read(mapSheetVisibilityStateProvider.notifier).hide();
      ref.read(mapPlaceSelectionProvider.notifier).clear();
      unawaited(LaunchDetailRoute(launchId: launch.id).push<void>(context));
    }

    final planning = ref.watch(routePlanningProvider);
    if (planning.planningMode && planning.waypoints.length >= 2) {
      ref.watch(
        routeGoNoGoRollupProvider(
          RouteGoNoGoWaypointsKey.fromOrdered(
            planning.waypoints.map((w) => w.id).toList(),
          ),
        ),
      );
    }

    final routeGoNoGoSection = planning.waypoints.length >= 2
        ? MapRouteGoNoGoSection(
            launchIdsInOrder: planning.waypoints.map((w) => w.id).toList(),
          )
        : null;

    if (_integrationMapStub) {
      return MapScreen(
        mapSlot: const SizedBox(key: Key('integration_map_stub')),
        onOpenLaunchDetail: onOpenLaunchDetail,
        onSaveRoute: () => unawaited(showMapSaveRouteSheet(context, ref)),
        routeGoNoGoSection: routeGoNoGoSection,
      );
    }
    return MapScreen(
      onOpenLaunchDetail: onOpenLaunchDetail,
      onSaveRoute: () => unawaited(showMapSaveRouteSheet(context, ref)),
      routeGoNoGoSection: routeGoNoGoSection,
    );
  }
}

@TypedGoRoute<LaunchDetailRoute>(
  path: RoutePaths.launchDetail,
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<NearbyTripsSearchRoute>(
      path: RoutePaths.nearbyTripsSearchSegment,
    ),
  ],
)
class LaunchDetailRoute extends GoRouteData with $LaunchDetailRoute {
  const LaunchDetailRoute({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      _LaunchDetailRouteBody(launchId: launchId);
}

class NearbyTripsSearchRoute extends GoRouteData with $NearbyTripsSearchRoute {
  const NearbyTripsSearchRoute({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      _NearbyTripsSearchRouteBody(launchId: launchId);
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
    goNoGoSection: SavedRouteGoNoGoSection(routeId: routeId),
  );
}

void _loadSavedRouteOnMap(
  BuildContext context,
  WidgetRef ref,
  SavedRoute route,
) {
  ref.read(pendingSavedRouteLoadProvider.notifier).queueDraft(route);
  unawaited(
    ref
        .read(analyticsClientProvider)
        .logEvent(
          const AnalyticsEvent(name: AnalyticsEvents.savedRouteLoadOnMap),
        ),
  );
  const MapRoute().go(context);
  StatefulNavigationShell.maybeOf(context)?.goBranch(AppShellBranches.map);
}

/// Pre-fills route planning when picking a destination from nearby trips
/// search.
void planTripFromLaunchToDestination(
  WidgetRef ref, {
  required LaunchPoint origin,
  required LaunchPoint destination,
}) {
  ref
      .read(routePlanningProvider.notifier)
      .startPlanFromHereTo(
        putIn: origin,
        takeOut: destination,
      );
  ref.read(mapPlaceSelectionProvider.notifier).pickLaunch(origin);
  ref.read(tripsFromHereRoutePendingProvider.notifier).markPending();
  ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningEdit();
  ref.read(nearbyTripsSearchOriginProvider.notifier).close();
}

class _LaunchDetailRouteBody extends ConsumerWidget {
  const _LaunchDetailRouteBody({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launchAsync = ref.watch(launchPointByIdProvider(launchId));
    final l10n = context.l10n;
    return launchAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) {
        if (error is NotFoundFailure) {
          return const _ScreenViewLogger(
            screenName: AnalyticsScreenNames.launchNotFound,
            child: LaunchNotFoundScreen(),
          );
        }
        return _LaunchRouteErrorBody(
          title: l10n.launchDetailUnavailable,
          message: error is AppFailure
              ? error.message
              : l10n.launchDetailUnavailable,
        );
      },
      data: (launch) => _ScreenViewLogger(
        screenName: AnalyticsScreenNames.launchDetail,
        child: LaunchDetailScreen(
          launch: launch,
          tripsFromHereSection: _LaunchDetailSuggestedTripsEntry(
            originLaunch: launch,
          ),
        ),
      ),
    );
  }
}

/// Suggested-trips entry on launch detail; opens full-screen nearby search.
class _LaunchDetailSuggestedTripsEntry extends ConsumerWidget {
  const _LaunchDetailSuggestedTripsEntry({required this.originLaunch});

  final LaunchPoint originLaunch;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SuggestedTripsEntryTile(
    originLaunch: originLaunch,
    onOpen: () {
      unawaited(
        NearbyTripsSearchRoute(launchId: originLaunch.id).push<void>(context),
      );
    },
  );
}

class _NearbyTripsSearchRouteBody extends ConsumerWidget {
  const _NearbyTripsSearchRouteBody({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launchAsync = ref.watch(launchPointByIdProvider(launchId));
    return launchAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      data: (originLaunch) => _ScreenViewLogger(
        screenName: AnalyticsScreenNames.nearbyTripsSearch,
        child: NearbyTripsSearchPage(
          originLaunch: originLaunch,
          onLaunchSelected: (destination) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              planTripFromLaunchToDestination(
                ref,
                origin: originLaunch,
                destination: destination,
              );
              const MapRoute().go(context);
              ref
                  .read(tripsFromHereRoutePendingProvider.notifier)
                  .markPending();
            });
          },
        ),
      ),
    );
  }
}

/// Fallback when launch lookup fails for reasons other than an unknown id.
class _LaunchRouteErrorBody extends StatelessWidget {
  const _LaunchRouteErrorBody({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}

/// Logs a screen view once when [child] is first shown.
class _ScreenViewLogger extends ConsumerStatefulWidget {
  const _ScreenViewLogger({
    required this.screenName,
    required this.child,
  });

  final String screenName;
  final Widget child;

  @override
  ConsumerState<_ScreenViewLogger> createState() => _ScreenViewLoggerState();
}

class _ScreenViewLoggerState extends ConsumerState<_ScreenViewLogger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(
        ref
            .read(analyticsClientProvider)
            .logScreenView(screenName: widget.screenName),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
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

@TypedGoRoute<ModerationReportsRoute>(path: RoutePaths.moderationReports)
class ModerationReportsRoute extends GoRouteData with $ModerationReportsRoute {
  const ModerationReportsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ModerationQueueScreen();
}
