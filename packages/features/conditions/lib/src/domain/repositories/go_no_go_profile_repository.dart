import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Persists the user's skill profile for wind-tier go/no-go evaluation.
abstract interface class GoNoGoProfileRepository {
  /// Reads the saved profile or default when unset.
  FutureResult<GoNoGoProfile, AppFailure> read();

  /// Persists [profile].
  FutureResult<void, AppFailure> write(GoNoGoProfile profile);
}
