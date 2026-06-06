import 'package:eddyscout_core/eddyscout_core.dart';

/// Maps hydro GeoJSON load/parse errors to [AppFailure] for package boundaries.
AppFailure mapHydroToAppFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppFailure) {
    return error;
  }
  if (error is FormatException) {
    return ParseFailure(stackTrace: stackTrace);
  }
  return AssetLoadFailure(stackTrace: stackTrace);
}
