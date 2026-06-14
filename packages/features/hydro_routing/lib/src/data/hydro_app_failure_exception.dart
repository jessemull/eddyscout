import 'package:eddyscout_core/eddyscout_core.dart';

export 'package:eddyscout_core/eddyscout_core.dart'
    show AppFailureException, appFailureFrom;

/// Back-compat alias for hydro asset load failures.
typedef HydroAppFailureException = AppFailureException;

/// Back-compat alias for hydro asset load failures.
AppFailure? hydroAppFailureFrom(Object? error) => appFailureFrom(error);
