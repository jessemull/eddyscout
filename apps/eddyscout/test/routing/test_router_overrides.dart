import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter_riverpod/misc.dart';

/// Router wiring overrides required by tests that mount the app shell.
final List<Override> appRouterTestOverrides = [
  routesProvider.overrideWithValue($appRoutes),
  isKnownLaunchIdProvider.overrideWithValue(
    (launchId) => findLaunchPointById(launchId) != null,
  ),
  savedRoutesDatabaseProvider.overrideWith(
    (ref) async => openSavedRoutesDatabaseForTest(),
  ),
  launchPointLookupProvider.overrideWithValue(findLaunchPointById),
  navigatorObserversProvider.overrideWithValue(const []),
  analyticsClientProvider.overrideWithValue(RecordingAnalyticsClient()),
];
