import 'package:eddyscout_core/eddyscout_core.dart';

/// Persists and reads user-saved planned routes locally.
abstract interface class SavedRouteRepository {
  /// All routes ordered by most recently updated.
  FutureResult<List<SavedRoute>, AppFailure> listAll();

  /// Favorite routes ordered by most recently updated.
  FutureResult<List<SavedRoute>, AppFailure> listFavorites();

  /// Single route by id, or null when missing.
  FutureResult<SavedRoute?, AppFailure> getById(String id);

  /// Inserts or updates [route].
  FutureResult<SavedRoute, AppFailure> upsert(SavedRoute route);

  /// Deletes a route by id.
  FutureResult<void, AppFailure> delete(String id);

  /// Updates favorite flag for [id].
  FutureResult<SavedRoute, AppFailure> setFavorite(
    String id, {
    required bool isFavorite,
  });
}
