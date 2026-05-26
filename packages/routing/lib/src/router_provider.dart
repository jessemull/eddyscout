import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Lightweight router factory shared by the app and feature shells.
///
/// Route definitions live at the app boundary until feature packages own their
/// routes, but we still centralize creation options (initial location,
/// redirect hook) in this package so it remains testable and consistent.
GoRouter createRouter({
  required List<RouteBase> routes,
  String initialLocation = '/',
  String? Function(BuildContext context, GoRouterState state)? redirect,
  List<NavigatorObserver> observers = const <NavigatorObserver>[],
}) => GoRouter(
  routes: routes,
  initialLocation: initialLocation,
  redirect: redirect,
  observers: observers,
);
