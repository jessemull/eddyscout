import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout/screens/launch_detail_screen.dart';
import 'package:eddyscout/screens/map_screen.dart';
import 'package:eddyscout/screens/missing_mapbox_token_screen.dart';
import 'package:eddyscout/screens/web_map_placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

@TypedGoRoute<MapRoute>(path: '/')
class MapRoute extends GoRouteData {
  const MapRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MapScreen();
  }
}

@TypedGoRoute<LaunchDetailRoute>(path: '/launch/:launchId')
class LaunchDetailRoute extends GoRouteData {
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
class MissingMapboxTokenRoute extends GoRouteData {
  const MissingMapboxTokenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MissingMapboxTokenScreen();
  }
}

@TypedGoRoute<WebMapPlaceholderRoute>(path: '/web')
class WebMapPlaceholderRoute extends GoRouteData {
  const WebMapPlaceholderRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebMapPlaceholderScreen();
  }
}

/// Fallback when a deep link references an unknown launch id.
class _LaunchNotFoundBody extends StatelessWidget {
  const _LaunchNotFoundBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Launch not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'That launch is not in the curated list.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
