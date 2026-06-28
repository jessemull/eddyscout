/// Moderation outcome for a condition report.
enum ConditionReportModerationStatus {
  /// Visible to other paddlers.
  approved,

  /// Awaiting moderator review.
  held,

  /// Hidden after moderator or policy action.
  rejected,
}

/// Parses server moderation status strings.
ConditionReportModerationStatus parseConditionReportModerationStatus(
  String raw,
) {
  return switch (raw) {
    'held' => ConditionReportModerationStatus.held,
    'rejected' => ConditionReportModerationStatus.rejected,
    _ => ConditionReportModerationStatus.approved,
  };
}

/// Result from `submitConditionReport`.
class ConditionReportSubmitResult {
  /// Creates a parsed submit response.
  const ConditionReportSubmitResult({required this.moderationStatus});

  /// Parses Callable JSON into a submit result.
  factory ConditionReportSubmitResult.fromJson(Map<Object?, Object?> json) {
    final status = json['moderationStatus'];
    if (status is! String) {
      return const ConditionReportSubmitResult(
        moderationStatus: ConditionReportModerationStatus.approved,
      );
    }
    return ConditionReportSubmitResult(
      moderationStatus: parseConditionReportModerationStatus(status),
    );
  }

  /// Whether the report is publicly visible immediately.
  final ConditionReportModerationStatus moderationStatus;

  /// True when the report passed automated checks and is live.
  bool get isPubliclyVisible =>
      moderationStatus == ConditionReportModerationStatus.approved;
}

/// One row from `listConditionReports` (no raw UIDs; [isMine] for UI only).
class ConditionReportListItem {
  /// Creates a parsed community report row.
  const ConditionReportListItem({
    required this.message,
    required this.createdAt,
    required this.isMine,
  });

  /// Parses a Callable JSON map into a list item.
  factory ConditionReportListItem.fromJson(Map<Object?, Object?> json) {
    final message = json['message'];
    final createdAt = json['createdAt'];
    final isMine = json['isMine'];
    if (message is! String || createdAt is! String || isMine is! bool) {
      throw const FormatException('ConditionReportListItem');
    }
    return ConditionReportListItem(
      message: message,
      createdAt: DateTime.parse(createdAt),
      isMine: isMine,
    );
  }

  /// Paddler-submitted note text.
  final String message;

  /// Server timestamp for sort order and staleness cues.
  final DateTime createdAt;

  /// Whether the current signed-in user authored this report.
  final bool isMine;
}

/// Public list payload from `listConditionReports`.
class ConditionReportsListResult {
  /// Creates a parsed list response.
  const ConditionReportsListResult({
    required this.reports,
    required this.viewerHasPendingReport,
  });

  /// Parses Callable JSON into list metadata and rows.
  factory ConditionReportsListResult.fromJson(Map<Object?, Object?> json) {
    final raw = json['reports'];
    if (raw is! List) {
      throw const FormatException('ConditionReportsListResult');
    }
    final viewerHasPendingReport = json['viewerHasPendingReport'];
    return ConditionReportsListResult(
      reports: raw
          .map(
            (e) => ConditionReportListItem.fromJson(
              Map<Object?, Object?>.from(e as Map),
            ),
          )
          .toList(),
      viewerHasPendingReport:
          viewerHasPendingReport is bool && viewerHasPendingReport,
    );
  }

  /// Approved reports for the launch.
  final List<ConditionReportListItem> reports;

  /// True when the caller has a held report on this launch.
  final bool viewerHasPendingReport;
}

/// Sort order for the pending moderation queue.
enum ModerationQueueSort {
  /// Oldest submissions first (longest waiting).
  createdAtAsc,

  /// Newest submissions first.
  createdAtDesc,
}

/// Sort order for moderation history.
enum ModerationHistorySort {
  /// Most recently reviewed first.
  reviewedAtDesc,

  /// Oldest review action first.
  reviewedAtAsc,
}

/// Status filter for moderation history.
enum ModerationHistoryStatusFilter {
  /// All moderated outcomes.
  all,

  /// Approved reports only.
  approved,

  /// Rejected reports only.
  rejected,
}

/// Server query parameters for the pending queue.
class ModerationQueueQuery {
  /// Creates pending queue filters.
  const ModerationQueueQuery({
    this.limit = 25,
    this.launchId,
    this.createdAfter,
    this.createdBefore,
    this.sort = ModerationQueueSort.createdAtAsc,
  });

  /// Maximum rows to fetch.
  final int limit;

  /// Exact launch id filter.
  final String? launchId;

  /// Include reports submitted on or after this instant.
  final DateTime? createdAfter;

  /// Include reports submitted on or before this instant.
  final DateTime? createdBefore;

  /// Sort direction for submission time.
  final ModerationQueueSort sort;
}

/// Server query parameters for moderation history.
class ModerationHistoryQuery {
  /// Creates history filters.
  const ModerationHistoryQuery({
    this.limit = 25,
    this.launchId,
    this.status = ModerationHistoryStatusFilter.all,
    this.reviewedAfter,
    this.reviewedBefore,
    this.sort = ModerationHistorySort.reviewedAtDesc,
  });

  /// Maximum rows to fetch.
  final int limit;

  /// Exact launch id filter.
  final String? launchId;

  /// Outcome filter.
  final ModerationHistoryStatusFilter status;

  /// Include rows reviewed on or after this instant.
  final DateTime? reviewedAfter;

  /// Include rows reviewed on or before this instant.
  final DateTime? reviewedBefore;

  /// Sort direction for review time.
  final ModerationHistorySort sort;
}

/// One failed row from batch moderation.
class ModerationBatchFailure {
  /// Creates a parsed batch failure row.
  const ModerationBatchFailure({
    required this.reportId,
    required this.code,
  });

  /// Parses Callable JSON.
  factory ModerationBatchFailure.fromJson(Map<Object?, Object?> json) {
    final reportId = json['reportId'];
    final code = json['code'];
    if (reportId is! String || code is! String) {
      throw const FormatException('ModerationBatchFailure');
    }
    return ModerationBatchFailure(reportId: reportId, code: code);
  }

  /// Report id that failed.
  final String reportId;

  /// Callable error code.
  final String code;
}

/// Result from batch moderation.
class ModerationBatchModerateResult {
  /// Creates a parsed batch result.
  const ModerationBatchModerateResult({
    required this.succeeded,
    required this.failed,
  });

  /// Parses Callable JSON.
  factory ModerationBatchModerateResult.fromJson(Map<Object?, Object?> json) {
    final succeededRaw = json['succeeded'];
    final failedRaw = json['failed'];
    if (succeededRaw is! List || failedRaw is! List) {
      throw const FormatException('ModerationBatchModerateResult');
    }
    return ModerationBatchModerateResult(
      succeeded: succeededRaw.cast<String>(),
      failed: failedRaw
          .map(
            (e) => ModerationBatchFailure.fromJson(
              Map<Object?, Object?>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  /// Report ids moderated successfully.
  final List<String> succeeded;

  /// Failures keyed by report id.
  final List<ModerationBatchFailure> failed;
}

/// One row in the moderator review queue.
class ModerationQueueReport {
  /// Creates a pending report row.
  const ModerationQueueReport({
    required this.id,
    required this.launchId,
    required this.message,
    required this.createdAt,
    required this.submitterUid,
    this.moderationReason,
    this.holdAgeDays,
  });

  /// Parses Callable JSON into a pending row.
  factory ModerationQueueReport.fromJson(Map<Object?, Object?> json) {
    final id = json['id'];
    final launchId = json['launchId'];
    final message = json['message'];
    final createdAt = json['createdAt'];
    final submitterUid = json['submitterUid'];
    if (id is! String ||
        launchId is! String ||
        message is! String ||
        createdAt is! String ||
        submitterUid is! String) {
      throw const FormatException('ModerationQueueReport');
    }
    final moderationReason = json['moderationReason'];
    final holdAgeDays = json['holdAgeDays'];
    return ModerationQueueReport(
      id: id,
      launchId: launchId,
      message: message,
      createdAt: DateTime.parse(createdAt),
      submitterUid: submitterUid,
      moderationReason: moderationReason is String ? moderationReason : null,
      holdAgeDays: holdAgeDays is int ? holdAgeDays : null,
    );
  }

  /// Firestore document id.
  final String id;

  /// Launch the report belongs to.
  final String launchId;

  /// Submitted message text.
  final String message;

  /// Submission timestamp.
  final DateTime createdAt;

  /// Anonymous auth uid of the submitter.
  final String submitterUid;

  /// Internal hold reason (e.g. keyword_hold).
  final String? moderationReason;

  /// Whole days waiting in the queue.
  final int? holdAgeDays;
}

/// One row in the moderator audit history.
class ModerationHistoryReport {
  /// Creates a history row.
  const ModerationHistoryReport({
    required this.id,
    required this.launchId,
    required this.message,
    required this.createdAt,
    required this.submitterUid,
    required this.moderationStatus,
    required this.reviewedAt,
    this.moderationReason,
    this.reviewedBy,
  });

  /// Parses Callable JSON into a history row.
  factory ModerationHistoryReport.fromJson(Map<Object?, Object?> json) {
    final id = json['id'];
    final launchId = json['launchId'];
    final message = json['message'];
    final createdAt = json['createdAt'];
    final submitterUid = json['submitterUid'];
    final moderationStatus = json['moderationStatus'];
    final reviewedAt = json['reviewedAt'];
    if (id is! String ||
        launchId is! String ||
        message is! String ||
        createdAt is! String ||
        submitterUid is! String ||
        moderationStatus is! String ||
        reviewedAt is! String) {
      throw const FormatException('ModerationHistoryReport');
    }
    final moderationReason = json['moderationReason'];
    final reviewedBy = json['reviewedBy'];
    return ModerationHistoryReport(
      id: id,
      launchId: launchId,
      message: message,
      createdAt: DateTime.parse(createdAt),
      submitterUid: submitterUid,
      moderationStatus: parseConditionReportModerationStatus(moderationStatus),
      moderationReason: moderationReason is String ? moderationReason : null,
      reviewedAt: DateTime.parse(reviewedAt),
      reviewedBy: reviewedBy is String ? reviewedBy : null,
    );
  }

  /// Firestore document id.
  final String id;

  /// Launch the report belongs to.
  final String launchId;

  /// Submitted message text.
  final String message;

  /// Submission timestamp.
  final DateTime createdAt;

  /// Anonymous auth uid of the submitter.
  final String submitterUid;

  /// Moderation outcome.
  final ConditionReportModerationStatus moderationStatus;

  /// Internal moderation reason.
  final String? moderationReason;

  /// When the moderation action occurred.
  final DateTime reviewedAt;

  /// Moderator uid, or null for system auto-release.
  final String? reviewedBy;
}

/// Result from `summarizeLaunchReports`.
class LaunchReportsDigestResult {
  /// Creates a digest response from Callable JSON.
  const LaunchReportsDigestResult({
    required this.digestText,
    required this.cached,
    required this.noReports,
  });

  /// Parses a Callable JSON map into a digest result.
  factory LaunchReportsDigestResult.fromJson(Map<Object?, Object?> json) {
    final digestText = json['digestText'];
    final cached = json['cached'];
    final noReports = json['noReports'];
    if (digestText is! String || cached is! bool) {
      throw const FormatException('LaunchReportsDigestResult');
    }
    return LaunchReportsDigestResult(
      digestText: digestText,
      cached: cached,
      noReports: noReports is bool && noReports,
    );
  }

  /// AI-generated summary of recent community reports.
  final String digestText;

  /// Whether the server returned a cached digest.
  final bool cached;

  /// True when there were no reports to summarize.
  final bool noReports;
}
