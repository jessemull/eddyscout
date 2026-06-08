import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'condition_reports_refresh_token_provider.g.dart';

/// Incremented after a paddler submits a condition report to refresh the list.
@riverpod
class ConditionReportsRefreshToken extends _$ConditionReportsRefreshToken {
  @override
  int build() => 0;

  /// Bumps the epoch so list providers watching this token refetch.
  void increment() => state++;
}
