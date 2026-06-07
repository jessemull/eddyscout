import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Lightweight router factory shared by the app and `packages/routing/`.
///
/// Typed routes are bound in `apps/eddyscout/lib/routing/app_routes.dart`;
/// this factory centralizes creation options (initial location, redirect hook,
/// observers) so router assembly stays testable and consistent.
GoRouter createRouter({
  required List<RouteBase> routes,
  String initialLocation = '/',
  String? Function(BuildContext context, GoRouterState state)? redirect,
  List<NavigatorObserver> observers = const <NavigatorObserver>[],
  bool debugLogDiagnostics = false,
}) => GoRouter(
  routes: routes,
  initialLocation: initialLocation,
  redirect: redirect,
  observers: observers,
  debugLogDiagnostics: debugLogDiagnostics,
);
