import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented after a paddler submits a condition report to refresh the list.
///
/// Lives in domain so data providers can watch without presentation imports.
/// `@riverpod` codegen pilot: `docs/examples/condition_reports_refresh_token_provider.riverpod_pilot.dart`
/// (requires workspace `flutter_riverpod` 3.x — see `docs/CODEGEN.md`).
class ConditionReportsRefreshTokenNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Bumps the epoch so list providers watching this token refetch.
  void increment() => state++;
}

/// Refresh epoch for condition report list providers.
final NotifierProvider<ConditionReportsRefreshTokenNotifier, int>
conditionReportsRefreshTokenProvider =
    NotifierProvider.autoDispose<ConditionReportsRefreshTokenNotifier, int>(
      ConditionReportsRefreshTokenNotifier.new,
    );
