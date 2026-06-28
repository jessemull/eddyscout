import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';

/// Resolves a human-readable launch label for moderation UI.
String resolveLaunchDisplayName(String launchId) {
  return findLaunchPointById(launchId)?.name ?? launchId;
}

/// Maps server-side moderation reason codes to user-facing copy.
String formatModerationReason(AppLocalizations l10n, String raw) {
  return switch (raw) {
    'keyword_hold' => l10n.moderationReasonKeywordHold,
    'admin_approve' => l10n.moderationReasonAdminApprove,
    'admin_reject' => l10n.moderationReasonAdminReject,
    'admin_reopen' => l10n.moderationReasonAdminReopen,
    'hold_timeout_release' => l10n.moderationReasonHoldTimeout,
    _ => raw.replaceAll('_', ' '),
  };
}

/// Truncates a Firebase uid for compact display.
String truncateUid(String uid, {int length = 8}) {
  if (uid.length <= length) {
    return uid;
  }
  return uid.substring(0, length);
}
