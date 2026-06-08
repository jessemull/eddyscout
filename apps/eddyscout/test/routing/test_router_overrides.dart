import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_riverpod/misc.dart';

/// Router wiring overrides required by tests that mount the app shell.
final List<Override> appRouterTestOverrides = [
  routesProvider.overrideWithValue($appRoutes),
];
