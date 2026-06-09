import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/routing/saved_routes_database_override.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter_riverpod/misc.dart';

/// Saved-routes and shell overrides for tests using shared app bootstrap overrides.
final List<Override> appShellTestOverrides = [
  ...savedRoutesTestOverrides(),
  launchPointLookupProvider.overrideWithValue(findLaunchPointById),
  navigatorObserversProvider.overrideWithValue(const []),
];

/// Router wiring overrides for tests that do not use shared bootstrap overrides.
final List<Override> appRouterTestOverrides = [
  routesProvider.overrideWithValue($appRoutes),
  ...appShellTestOverrides,
  analyticsClientProvider.overrideWithValue(RecordingAnalyticsClient()),
];
