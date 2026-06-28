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

/// One row in the moderator review queue.
class ModerationQueueReport {
  /// Creates a pending report row.
  const ModerationQueueReport({
    required this.id,
    required this.launchId,
    required this.message,
    required this.createdAt,
    this.moderationReason,
  });

  /// Parses Callable JSON into a pending row.
  factory ModerationQueueReport.fromJson(Map<Object?, Object?> json) {
    final id = json['id'];
    final launchId = json['launchId'];
    final message = json['message'];
    final createdAt = json['createdAt'];
    if (id is! String ||
        launchId is! String ||
        message is! String ||
        createdAt is! String) {
      throw const FormatException('ModerationQueueReport');
    }
    final moderationReason = json['moderationReason'];
    return ModerationQueueReport(
      id: id,
      launchId: launchId,
      message: message,
      createdAt: DateTime.parse(createdAt),
      moderationReason: moderationReason is String ? moderationReason : null,
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

  /// Internal hold reason (e.g. keyword_hold).
  final String? moderationReason;
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
