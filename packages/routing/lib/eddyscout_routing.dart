/// go_router-based navigation with typed routes.
library;

export 'src/app_redirect.dart';
// Hide codegen provider functions so `mapboxAccessToken` is not exported
// twice (const in app_redirect.dart; @riverpod fn in go_router_provider.dart).
export 'src/go_router_provider.dart'
    hide goRouter, isKnownLaunchId, mapboxAccessToken, routes;
export 'src/route_paths.dart';
export 'src/router_provider.dart';
