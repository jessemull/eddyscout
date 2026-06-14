/// How a planned route entered the map planner.
enum RouteOrigin {
  /// Computed along bundled hydro geometry between launches.
  planner,

  /// Loaded from an external GPX file.
  imported,
}
