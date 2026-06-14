/// Session phase for map-first route planning (replaces explicit mode toggle).
enum MapPlanningPhase {
  /// Map browse — no active place or route session.
  browse,

  /// A launch is selected; place bottom sheet is visible.
  placeSelected,

  /// Planning paddle — start set, selecting destination or stops.
  planning,

  /// At least two waypoints with computed route geometry.
  routeReady,
}
