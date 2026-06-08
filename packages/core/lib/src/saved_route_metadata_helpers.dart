import 'package:eddyscout_core/src/launch_models.dart';
import 'package:eddyscout_core/src/saved_route_models.dart';

/// Aggregates metadata fields from resolved launch points.
SavedRouteMetadata computeSavedRouteMetadata({
  required Iterable<LaunchPoint> launches,
  double? distanceMeters,
  WindExposure? exposureOverride,
  TideRelevance? tideOverride,
}) {
  WindExposure? maxExposure;
  TideRelevance? maxTide;
  for (final launch in launches) {
    maxExposure = _maxWindExposure(maxExposure, launch.windExposure);
    maxTide = _maxTideRelevance(maxTide, launch.tideRelevance);
  }
  return SavedRouteMetadata(
    distanceMeters: distanceMeters,
    exposure: exposureOverride ?? maxExposure,
    tideDependency: tideOverride ?? maxTide,
  );
}

WindExposure? _maxWindExposure(WindExposure? current, WindExposure next) {
  if (current == null) {
    return next;
  }
  return _windExposureRank(next) > _windExposureRank(current) ? next : current;
}

int _windExposureRank(WindExposure exposure) => switch (exposure) {
  WindExposure.sheltered => 0,
  WindExposure.moderate => 1,
  WindExposure.exposed => 2,
};

TideRelevance? _maxTideRelevance(TideRelevance? current, TideRelevance next) {
  if (current == null) {
    return next;
  }
  return _tideRelevanceRank(next) > _tideRelevanceRank(current)
      ? next
      : current;
}

int _tideRelevanceRank(TideRelevance relevance) => switch (relevance) {
  TideRelevance.none => 0,
  TideRelevance.minor => 1,
  TideRelevance.major => 2,
};
