import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eddyscout_persistence/src/database/saved_routes_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'saved_routes_database.g.dart';

/// Opens a file-backed saved routes database in app documents.
Future<SavedRoutesDatabase> openSavedRoutesDatabase() async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'saved_routes.sqlite'));
  return SavedRoutesDatabase(
    LazyDatabase(() async => NativeDatabase.createInBackground(file)),
  );
}

/// Opens an in-memory database for tests.
SavedRoutesDatabase openSavedRoutesDatabaseForTest() =>
    SavedRoutesDatabase(NativeDatabase.memory());

@DriftDatabase(tables: [SavedRoutes])
/// SQLite database for locally saved planned routes.
class SavedRoutesDatabase extends _$SavedRoutesDatabase {
  /// Creates a database with the given query executor.
  SavedRoutesDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// All routes ordered by most recently updated.
  Future<List<SavedRouteRow>> getAllRoutes() => (select(
    savedRoutes,
  )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

  /// Favorite routes ordered by most recently updated.
  Future<List<SavedRouteRow>> getFavoriteRoutes() =>
      (select(savedRoutes)
            ..where((t) => t.isFavorite.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  /// Single route by id, or null when missing.
  Future<SavedRouteRow?> getRouteById(String id) =>
      (select(savedRoutes)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Inserts or replaces a route row.
  Future<void> upsertRoute(SavedRoutesCompanion row) =>
      into(savedRoutes).insertOnConflictUpdate(row);

  /// Deletes a route by id; returns whether a row was removed.
  Future<bool> deleteRoute(String id) async {
    final deleted = await (delete(
      savedRoutes,
    )..where((t) => t.id.equals(id))).go();
    return deleted > 0;
  }

  /// Updates favorite flag; returns whether a row was updated.
  Future<bool> setFavorite({
    required String id,
    required bool isFavorite,
    required int updatedAtMs,
  }) async {
    final updated = await (update(savedRoutes)..where((t) => t.id.equals(id)))
        .write(
          SavedRoutesCompanion(
            isFavorite: Value(isFavorite),
            updatedAt: Value(updatedAtMs),
          ),
        );
    return updated > 0;
  }
}
