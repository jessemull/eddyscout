import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Lightweight router factory shared by the app and feature shells.
///
/// Route lists are assembled in the app shell (`app_routes.dart`); this package
/// centralizes router creation options (initial location, redirect hook,
/// observers) so wiring stays testable and consistent.
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
