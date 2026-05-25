import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented after a paddler submits a condition report to refresh the list.
///
/// Lives in domain so data providers can watch without presentation imports.
final AutoDisposeStateProvider<int> conditionReportsRefreshTokenProvider =
    StateProvider.autoDispose<int>(
      (ref) => 0,
    );
