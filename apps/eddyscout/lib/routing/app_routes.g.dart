// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $appShellRouteData,
  $mapRoute,
  $launchDetailRoute,
  $savedRoutesListRoute,
  $savedRouteDetailRoute,
  $missingMapboxTokenRoute,
  $webMapPlaceholderRoute,
];

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
  factory: $AppShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      navigatorKey: MapShellBranchData.$navigatorKey,
      routes: [
        GoRouteData.$route(path: '/', factory: $MapRoute._fromState),
        GoRouteData.$route(
          path: '/launch/:launchId',
          factory: $LaunchDetailRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: SavedRoutesShellBranchData.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/saved-routes',
          factory: $SavedRoutesListRoute._fromState,
        ),
        GoRouteData.$route(
          path: '/saved-routes/:routeId',
          factory: $SavedRouteDetailRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $AppShellRouteDataExtension on AppShellRouteData {
  static AppShellRouteData _fromState(GoRouterState state) =>
      const AppShellRouteData();
}

mixin $MapRoute on GoRouteData {
  static MapRoute _fromState(GoRouterState state) => const MapRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $LaunchDetailRoute on GoRouteData {
  static LaunchDetailRoute _fromState(GoRouterState state) =>
      LaunchDetailRoute(launchId: state.pathParameters['launchId']!);

  LaunchDetailRoute get _self => this as LaunchDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/launch/${Uri.encodeComponent(_self.launchId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SavedRoutesListRoute on GoRouteData {
  static SavedRoutesListRoute _fromState(GoRouterState state) =>
      const SavedRoutesListRoute();

  @override
  String get location => GoRouteData.$location('/saved-routes');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SavedRouteDetailRoute on GoRouteData {
  static SavedRouteDetailRoute _fromState(GoRouterState state) =>
      SavedRouteDetailRoute(routeId: state.pathParameters['routeId']!);

  SavedRouteDetailRoute get _self => this as SavedRouteDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/saved-routes/${Uri.encodeComponent(_self.routeId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mapRoute =>
    GoRouteData.$route(path: '/', factory: $MapRoute._fromState);

RouteBase get $launchDetailRoute => GoRouteData.$route(
  path: '/launch/:launchId',
  factory: $LaunchDetailRoute._fromState,
);

RouteBase get $savedRoutesListRoute => GoRouteData.$route(
  path: '/saved-routes',
  factory: $SavedRoutesListRoute._fromState,
);

RouteBase get $savedRouteDetailRoute => GoRouteData.$route(
  path: '/saved-routes/:routeId',
  factory: $SavedRouteDetailRoute._fromState,
);

RouteBase get $missingMapboxTokenRoute => GoRouteData.$route(
  path: '/missing-token',
  factory: $MissingMapboxTokenRoute._fromState,
);

mixin $MissingMapboxTokenRoute on GoRouteData {
  static MissingMapboxTokenRoute _fromState(GoRouterState state) =>
      const MissingMapboxTokenRoute();

  @override
  String get location => GoRouteData.$location('/missing-token');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $webMapPlaceholderRoute => GoRouteData.$route(
  path: '/web',
  factory: $WebMapPlaceholderRoute._fromState,
);

mixin $WebMapPlaceholderRoute on GoRouteData {
  static WebMapPlaceholderRoute _fromState(GoRouterState state) =>
      const WebMapPlaceholderRoute();

  @override
  String get location => GoRouteData.$location('/web');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
