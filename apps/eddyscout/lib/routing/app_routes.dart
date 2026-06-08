import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

const _integrationMapStub = bool.fromEnvironment('INTEGRATION_MAP_STUB');

@TypedGoRoute<MapRoute>(path: RoutePaths.map)
class MapRoute extends GoRouteData with $MapRoute {
  const MapRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    void onOpenLaunchDetail(LaunchPoint launch) {
      unawaited(LaunchDetailRoute(launchId: launch.id).push<void>(context));
    }

    if (_integrationMapStub) {
      return MapScreen(
        mapSlot: const SizedBox(key: Key('integration_map_stub')),
        onOpenLaunchDetail: onOpenLaunchDetail,
      );
    }
    return MapScreen(onOpenLaunchDetail: onOpenLaunchDetail);
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
        child: LaunchDetailScreen(launch: launch),
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
