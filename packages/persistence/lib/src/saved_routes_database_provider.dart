import 'package:eddyscout_persistence/src/database/saved_routes_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_routes_database_provider.g.dart';

/// App-wide saved routes Drift database.
///
/// Override in tests with [openSavedRoutesDatabaseForTest].
@Riverpod(keepAlive: true)
Future<SavedRoutesDatabase> savedRoutesDatabase(Ref ref) async {
  final db = await openSavedRoutesDatabase();
  ref.onDispose(db.close);
  return db;
}
