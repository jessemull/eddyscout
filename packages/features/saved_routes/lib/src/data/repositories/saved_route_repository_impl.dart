import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/data/mappers/saved_route_row_mapper.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:flutter/foundation.dart';

/// Drift-backed local persistence for saved routes.
class SavedRouteRepositoryImpl implements SavedRouteRepository {
  /// Creates a repository backed by the given drift database.
  const SavedRouteRepositoryImpl(this._database);

  final SavedRoutesDatabase _database;

  List<SavedRoute> _routesFromRows(List<SavedRouteRow> rows) {
    final routes = <SavedRoute>[];
    for (final row in rows) {
      final route = trySavedRouteFromRow(row);
      if (route != null) {
        routes.add(route);
      } else {
        debugPrint(
          'saved_routes: skipped corrupt row id=${row.id} name=${row.name}',
        );
      }
    }
    return routes;
  }

  @override
  FutureResult<List<SavedRoute>, AppFailure> listAll() async {
    try {
      final rows = await _database.getAllRoutes();
      return Result.success(_routesFromRows(rows));
    } on Object catch (_, st) {
      return Result.failure(
        StorageFailure(message: 'Could not load saved routes.', stackTrace: st),
      );
    }
  }

  @override
  FutureResult<List<SavedRoute>, AppFailure> listFavorites() async {
    try {
      final rows = await _database.getFavoriteRoutes();
      return Result.success(_routesFromRows(rows));
    } on Object catch (_, st) {
      return Result.failure(
        StorageFailure(
          message: 'Could not load favorite routes.',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  FutureResult<SavedRoute?, AppFailure> getById(String id) async {
    try {
      final row = await _database.getRouteById(id);
      if (row == null) {
        return const Result.success(null);
      }
      try {
        return Result.success(savedRouteFromRow(row));
      } on Object catch (_, st) {
        return Result.failure(ParseFailure(stackTrace: st));
      }
    } on Object catch (_, st) {
      return Result.failure(
        StorageFailure(message: 'Could not load saved route.', stackTrace: st),
      );
    }
  }

  @override
  FutureResult<SavedRoute, AppFailure> upsert(SavedRoute route) async {
    try {
      await _database.upsertRoute(savedRouteToCompanion(route));
      return Result.success(route);
    } on Object catch (_, st) {
      return Result.failure(
        StorageFailure(message: 'Could not save route.', stackTrace: st),
      );
    }
  }

  @override
  FutureResult<void, AppFailure> delete(String id) async {
    try {
      final deleted = await _database.deleteRoute(id);
      if (!deleted) {
        return Result.failure(
          NotFoundFailure(message: 'Saved route not found: $id'),
        );
      }
      return const Result.success(null);
    } on Object catch (_, st) {
      return Result.failure(
        StorageFailure(message: 'Could not delete route.', stackTrace: st),
      );
    }
  }

  @override
  FutureResult<SavedRoute, AppFailure> setFavorite(
    String id, {
    required bool isFavorite,
  }) async {
    try {
      final existing = await _database.getRouteById(id);
      if (existing == null) {
        return Result.failure(
          NotFoundFailure(message: 'Saved route not found: $id'),
        );
      }
      final updatedAt = DateTime.now().millisecondsSinceEpoch;
      await _database.setFavorite(
        id: id,
        isFavorite: isFavorite,
        updatedAtMs: updatedAt,
      );
      final row = await _database.getRouteById(id);
      if (row == null) {
        return Result.failure(
          NotFoundFailure(message: 'Saved route not found: $id'),
        );
      }
      try {
        return Result.success(savedRouteFromRow(row));
      } on Object catch (_, st) {
        return Result.failure(ParseFailure(stackTrace: st));
      }
    } on Object catch (_, st) {
      return Result.failure(
        StorageFailure(
          message: 'Could not update favorite.',
          stackTrace: st,
        ),
      );
    }
  }
}
