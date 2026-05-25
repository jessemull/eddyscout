import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented after a paddler submits a condition report to refresh the list.
final conditionReportsRefreshTokenProvider = StateProvider.autoDispose<int>(
  (ref) => 0,
);
