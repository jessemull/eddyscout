import 'package:eddyscout_core/eddyscout_core.dart';

/// Maps hydro GeoJSON load/parse errors to [AppFailure] for package boundaries.
AppFailure mapHydroToAppFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppFailure) {
    return error;
  }
  if (error is FormatException) {
    return StorageFailure(
      message: 'River route data could not be read.',
      stackTrace: stackTrace,
    );
  }
  return UnexpectedFailure(
    message: 'River route data is unavailable.',
    stackTrace: stackTrace,
  );
}
