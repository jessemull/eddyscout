// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mapRoute,
  $launchDetailRoute,
  $missingMapboxTokenRoute,
  $webMapPlaceholderRoute,
];

RouteBase get $mapRoute =>
    GoRouteData.$route(path: '/', factory: $MapRoute._fromState);

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

RouteBase get $launchDetailRoute => GoRouteData.$route(
  path: '/launch/:launchId',
  factory: $LaunchDetailRoute._fromState,
);

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
