import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Opens the production saved-routes database and closes it on dispose.
Future<SavedRoutesDatabase> openProductionSavedRoutesDatabase(Ref ref) async {
  final db = await openSavedRoutesDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Opens an in-memory saved-routes database and closes it on dispose.
SavedRoutesDatabase openTestSavedRoutesDatabase(Ref ref) {
  final db = openSavedRoutesDatabaseForTest();
  ref.onDispose(db.close);
  return db;
}

/// Provider override for production Drift wiring in the app entrypoint.
Override savedRoutesDatabaseProductionOverride() =>
    savedRoutesDatabaseProvider.overrideWith(openProductionSavedRoutesDatabase);

/// Provider override for tests and integration harnesses.
Override savedRoutesDatabaseTestOverride() => savedRoutesDatabaseProvider
    .overrideWith((ref) async => openTestSavedRoutesDatabase(ref));
