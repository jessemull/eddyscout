import 'package:drift/drift.dart';

/// Local SQLite table for user-saved planned routes (v1).
@DataClassName('SavedRouteRow')
class SavedRoutes extends Table {
  /// Primary key — local generated id.
  TextColumn get id => text()();

  /// User-visible route name.
  TextColumn get name => text()();

  /// Optional longer description.
  TextColumn get description => text().nullable()();

  /// Free-form notes.
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// Whether the user marked this route as a favorite.
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  /// Private by default in v1 (no cloud sync).
  BoolColumn get isPrivate => boolean().withDefault(const Constant(true))();

  /// JSON array of route waypoints (core model).
  TextColumn get waypointsJson => text()();

  /// JSON object of route metadata (core model).
  TextColumn get metadataJson => text()();

  /// Optional JSON geometry snapshot (core model).
  TextColumn get geometryJson => text().nullable()();

  /// Created timestamp (Unix ms).
  IntColumn get createdAt => integer()();

  /// Last updated timestamp (Unix ms).
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
