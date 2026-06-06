import 'package:eddyscout/screens/launch_detail_screen.dart';
import 'package:eddyscout/screens/map_screen.dart';
import 'package:eddyscout/screens/missing_mapbox_token_screen.dart';
import 'package:eddyscout/screens/web_map_placeholder_screen.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

const _integrationMapStub = bool.fromEnvironment('INTEGRATION_MAP_STUB');

@TypedGoRoute<MapRoute>(path: '/')
class MapRoute extends GoRouteData with $MapRoute {
  const MapRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (_integrationMapStub) {
      return const MapScreen(
        mapSlot: SizedBox(key: Key('integration_map_stub')),
      );
    }
    return const MapScreen();
  }
}

@TypedGoRoute<LaunchDetailRoute>(path: '/launch/:launchId')
class LaunchDetailRoute extends GoRouteData with $LaunchDetailRoute {
  const LaunchDetailRoute({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final launch = launchPointById(launchId);
    if (launch == null) {
      return const _LaunchNotFoundBody();
    }
    return LaunchDetailScreen(launch: launch);
  }
}

@TypedGoRoute<MissingMapboxTokenRoute>(path: '/missing-token')
class MissingMapboxTokenRoute extends GoRouteData
    with $MissingMapboxTokenRoute {
  const MissingMapboxTokenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MissingMapboxTokenScreen();
}

@TypedGoRoute<WebMapPlaceholderRoute>(path: '/web')
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
