import 'package:eddyscout/routing/river_route_planner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bundled hydro graphs for river routing between launches.
final riverRoutePlannerProvider = FutureProvider<RiverRoutePlanner>((ref) {
  ref.keepAlive();
  return RiverRoutePlanner.load();
});
