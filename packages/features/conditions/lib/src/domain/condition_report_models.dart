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
