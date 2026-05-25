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
    GoRouteData.$route(path: '/', factory: $MapRouteExtension._fromState);

extension $MapRouteExtension on MapRoute {
  static MapRoute _fromState(GoRouterState state) => const MapRoute();

  String get location => GoRouteData.$location('/');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $launchDetailRoute => GoRouteData.$route(
  path: '/launch/:launchId',

  factory: $LaunchDetailRouteExtension._fromState,
);

extension $LaunchDetailRouteExtension on LaunchDetailRoute {
  static LaunchDetailRoute _fromState(GoRouterState state) =>
      LaunchDetailRoute(launchId: state.pathParameters['launchId']!);

  String get location =>
      GoRouteData.$location('/launch/${Uri.encodeComponent(launchId)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $missingMapboxTokenRoute => GoRouteData.$route(
  path: '/missing-token',

  factory: $MissingMapboxTokenRouteExtension._fromState,
);

extension $MissingMapboxTokenRouteExtension on MissingMapboxTokenRoute {
  static MissingMapboxTokenRoute _fromState(GoRouterState state) =>
      const MissingMapboxTokenRoute();

  String get location => GoRouteData.$location('/missing-token');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $webMapPlaceholderRoute => GoRouteData.$route(
  path: '/web',

  factory: $WebMapPlaceholderRouteExtension._fromState,
);

extension $WebMapPlaceholderRouteExtension on WebMapPlaceholderRoute {
  static WebMapPlaceholderRoute _fromState(GoRouterState state) =>
      const WebMapPlaceholderRoute();

  String get location => GoRouteData.$location('/web');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
