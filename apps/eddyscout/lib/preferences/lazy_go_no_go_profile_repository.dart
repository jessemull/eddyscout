import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/eddyscout_conditions_data.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Defers SharedPreferences open until the first profile read/write.
///
/// The composition root binds [goNoGoProfileRepositoryProvider] synchronously,
/// but [keyValueStoreProvider] is async. Using [AsyncValue.requireValue] there
/// throws on cold start before preferences finish opening.
class LazyGoNoGoProfileRepository implements GoNoGoProfileRepository {
  /// Creates a repository that waits for [keyValueStoreProvider].
  const LazyGoNoGoProfileRepository(this._ref);

  final Ref _ref;

  Future<GoNoGoProfileRepositoryImpl> _delegate() async {
    final store = await _ref.read(keyValueStoreProvider.future);
    return GoNoGoProfileRepositoryImpl(store);
  }

  @override
  FutureResult<GoNoGoProfile, AppFailure> read() async =>
      (await _delegate()).read();

  @override
  FutureResult<void, AppFailure> write(GoNoGoProfile profile) async =>
      (await _delegate()).write(profile);
}

/// App-level override for [goNoGoProfileRepositoryProvider].
Override lazyGoNoGoProfileRepositoryOverride() =>
    goNoGoProfileRepositoryProvider.overrideWith(
      LazyGoNoGoProfileRepository.new,
    );
