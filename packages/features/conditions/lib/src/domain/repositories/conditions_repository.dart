import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Loads environmental conditions for a launch (NOAA/NWS/Open-Meteo/USGS).
// ignore: one_member_abstracts -- repository port for tests and overrides
abstract interface class ConditionsRepository {
  /// Fetches weather, tides, marine, and river flow for [launch].
  FutureResult<ConditionsSnapshot, AppFailure> load(
    LaunchPoint launch, {
    CancelToken? cancelToken,
  });
}
