import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_display_helpers.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'moderation_queue_filters_provider.g.dart';

/// Submitted-date presets for queue filtering.
enum ModerationSubmittedDateFilter {
  /// No submitted-date filter.
  all,

  /// Submitted within the last seven days.
  last7Days,

  /// Submitted within the last thirty days.
  last30Days,
}

/// Reviewed-date presets for history filtering.
enum ModerationReviewedDateFilter {
  /// No reviewed-date filter.
  all,

  /// Reviewed within the last seven days.
  last7Days,

  /// Reviewed within the last thirty days.
  last30Days,
}

/// Pending-tab filter state.
class ModerationPendingFiltersState {
  /// Creates pending filters.
  const ModerationPendingFiltersState({
    this.launchQuery = '',
    this.submittedDateFilter = ModerationSubmittedDateFilter.all,
    this.sort = ModerationQueueSort.createdAtAsc,
    this.limit = 100,
  });

  /// Launch id search text (exact id when matched to catalog).
  final String launchQuery;

  /// Submitted-date preset.
  final ModerationSubmittedDateFilter submittedDateFilter;

  /// Sort order for the pending queue.
  final ModerationQueueSort sort;

  /// Maximum rows to request from the server.
  final int limit;

  /// Creates a copy with selective overrides.
  ModerationPendingFiltersState copyWith({
    String? launchQuery,
    ModerationSubmittedDateFilter? submittedDateFilter,
    ModerationQueueSort? sort,
    int? limit,
  }) {
    return ModerationPendingFiltersState(
      launchQuery: launchQuery ?? this.launchQuery,
      submittedDateFilter: submittedDateFilter ?? this.submittedDateFilter,
      sort: sort ?? this.sort,
      limit: limit ?? this.limit,
    );
  }
}

/// History-tab filter state.
class ModerationHistoryFiltersState {
  /// Creates history filters.
  const ModerationHistoryFiltersState({
    this.launchQuery = '',
    this.status = ModerationHistoryStatusFilter.all,
    this.reviewedDateFilter = ModerationReviewedDateFilter.all,
    this.sort = ModerationHistorySort.reviewedAtDesc,
    this.limit = 100,
  });

  /// Launch id search text.
  final String launchQuery;

  /// Outcome filter.
  final ModerationHistoryStatusFilter status;

  /// Reviewed-date preset.
  final ModerationReviewedDateFilter reviewedDateFilter;

  /// Sort order for history.
  final ModerationHistorySort sort;

  /// Maximum rows to request from the server.
  final int limit;

  /// Creates a copy with selective overrides.
  ModerationHistoryFiltersState copyWith({
    String? launchQuery,
    ModerationHistoryStatusFilter? status,
    ModerationReviewedDateFilter? reviewedDateFilter,
    ModerationHistorySort? sort,
    int? limit,
  }) {
    return ModerationHistoryFiltersState(
      launchQuery: launchQuery ?? this.launchQuery,
      status: status ?? this.status,
      reviewedDateFilter: reviewedDateFilter ?? this.reviewedDateFilter,
      sort: sort ?? this.sort,
      limit: limit ?? this.limit,
    );
  }
}

/// Pending queue filter state for the moderation screen.
@riverpod
class ModerationPendingFilters extends _$ModerationPendingFilters {
  @override
  ModerationPendingFiltersState build() =>
      const ModerationPendingFiltersState();

  /// Updates launch search text.
  void setLaunchQuery(String value) {
    state = state.copyWith(launchQuery: value.trim());
  }

  /// Updates submitted-date preset.
  void setSubmittedDateFilter(ModerationSubmittedDateFilter value) {
    state = state.copyWith(submittedDateFilter: value);
  }

  /// Updates sort order.
  void setSort(ModerationQueueSort value) {
    state = state.copyWith(sort: value);
  }
}

/// History filter state for the moderation screen.
@riverpod
class ModerationHistoryFilters extends _$ModerationHistoryFilters {
  @override
  ModerationHistoryFiltersState build() =>
      const ModerationHistoryFiltersState();

  /// Updates launch search text.
  void setLaunchQuery(String value) {
    state = state.copyWith(launchQuery: value.trim());
  }

  /// Updates outcome filter.
  void setStatus(ModerationHistoryStatusFilter value) {
    state = state.copyWith(status: value);
  }

  /// Updates reviewed-date preset.
  void setReviewedDateFilter(ModerationReviewedDateFilter value) {
    state = state.copyWith(reviewedDateFilter: value);
  }

  /// Updates sort order.
  void setSort(ModerationHistorySort value) {
    state = state.copyWith(sort: value);
  }
}

DateTime? submittedAfterForFilter(ModerationSubmittedDateFilter filter) {
  final now = DateTime.now().toUtc();
  return switch (filter) {
    ModerationSubmittedDateFilter.all => null,
    ModerationSubmittedDateFilter.last7Days => now.subtract(
      const Duration(days: 7),
    ),
    ModerationSubmittedDateFilter.last30Days => now.subtract(
      const Duration(days: 30),
    ),
  };
}

DateTime? reviewedAfterForFilter(ModerationReviewedDateFilter filter) {
  final now = DateTime.now().toUtc();
  return switch (filter) {
    ModerationReviewedDateFilter.all => null,
    ModerationReviewedDateFilter.last7Days => now.subtract(
      const Duration(days: 7),
    ),
    ModerationReviewedDateFilter.last30Days => now.subtract(
      const Duration(days: 30),
    ),
  };
}

String? resolveLaunchIdFilter(String launchQuery) {
  final trimmed = launchQuery.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (findLaunchPointById(trimmed) != null) {
    return trimmed;
  }
  return null;
}

List<ModerationQueueReport> filterPendingReportsClientSide({
  required List<ModerationQueueReport> reports,
  required String launchQuery,
}) {
  final trimmed = launchQuery.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return reports;
  }
  return reports
      .where(
        (report) =>
            report.launchId.toLowerCase().contains(trimmed) ||
            (resolveLaunchDisplayName(report.launchId).toLowerCase().contains(
              trimmed,
            )),
      )
      .toList(growable: false);
}

List<ModerationHistoryReport> filterHistoryReportsClientSide({
  required List<ModerationHistoryReport> reports,
  required String launchQuery,
}) {
  final trimmed = launchQuery.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return reports;
  }
  return reports
      .where(
        (report) =>
            report.launchId.toLowerCase().contains(trimmed) ||
            (resolveLaunchDisplayName(report.launchId).toLowerCase().contains(
              trimmed,
            )),
      )
      .toList(growable: false);
}
