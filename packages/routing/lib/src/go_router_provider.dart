import 'package:eddyscout_routing/src/app_redirect.dart';
import 'package:eddyscout_routing/src/router_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App route list supplied by the composition root via [ProviderScope]
/// override.
final routesProvider = Provider<List<RouteBase>>(
  (ref) => throw UnimplementedError(
    'Override routesProvider with app route list in ProviderScope',
  ),
);

/// Application [GoRouter] with typed routes and platform/token redirects.
final goRouterProvider = Provider<GoRouter>(
  (ref) => createRouter(
    routes: ref.watch(routesProvider),
    initialLocation: initialAppLocation(),
    debugLogDiagnostics: kDebugMode,
    redirect: appRedirect,
  ),
);
