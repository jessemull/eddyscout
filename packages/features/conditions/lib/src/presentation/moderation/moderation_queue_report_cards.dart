part of 'moderation_queue_screen.dart';

class _PendingReportCard extends ConsumerStatefulWidget {
  const _PendingReportCard({
    required this.report,
    required this.bulkSelectActive,
    required this.selected,
    required this.onSelectedChanged,
    super.key,
  });

  final ModerationQueueReport report;
  final bool bulkSelectActive;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;

  @override
  ConsumerState<_PendingReportCard> createState() => _PendingReportCardState();
}

class _PendingReportCardState extends ConsumerState<_PendingReportCard> {
  var _busy = false;

  Future<void> _moderate({required bool approve}) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final ok = await ref
        .read(moderationPendingReportsProvider.notifier)
        .moderate(reportId: widget.report.id, approve: approve);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.moderationActionError)),
      );
    } else if (widget.selected) {
      ref.read(moderationSelectionProvider.notifier).toggle(widget.report.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    final launchName = resolveLaunchDisplayName(report.launchId);
    final submittedAt = report.createdAt.toLocal();
    final submittedTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(submittedAt));
    final submittedLabel =
        '${MaterialLocalizations.of(context).formatShortDate(submittedAt)} · '
        '$submittedTime';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.bulkSelectActive) ...[
              Transform.translate(
                offset: const Offset(0, -2),
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  value: widget.selected,
                  onChanged: _busy
                      ? null
                      : (value) => widget.onSelectedChanged(value ?? false),
                ),
              ),
              const SizedBox(width: Spacing.xs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(bottom: Spacing.xs),
                      child: LinearProgressIndicator(),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          launchName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (report.holdAgeDays != null)
                        Text(
                          l10n.moderationWaitingDays(report.holdAgeDays!),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                  Text(
                    submittedLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ModerationSubmitterField(
                          label: l10n.moderationSubmitterUid,
                          uid: report.submitterUid,
                        ),
                      ),
                      if (report.moderationReason != null) ...[
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: _ModerationLabeledText(
                            label: l10n.moderationHoldReason,
                            value: formatModerationReason(
                              l10n,
                              report.moderationReason!,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  _ModerationMessageField(
                    label: l10n.moderationMessage,
                    message: report.message,
                  ),
                  if (!widget.bulkSelectActive) ...[
                    const SizedBox(height: Spacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _moderate(approve: false),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                            ),
                          ),
                          child: Text(l10n.moderationReject),
                        ),
                        FilledButton.tonal(
                          onPressed: _busy
                              ? null
                              : () => _moderate(approve: true),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                            ),
                          ),
                          child: Text(l10n.moderationApprove),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryReportCard extends ConsumerStatefulWidget {
  const _HistoryReportCard({required this.report, super.key});

  final ModerationHistoryReport report;

  @override
  ConsumerState<_HistoryReportCard> createState() => _HistoryReportCardState();
}

class _HistoryReportCardState extends ConsumerState<_HistoryReportCard> {
  var _busy = false;

  Future<void> _confirmReopen() async {
    if (_busy) {
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.moderationReturnToPendingConfirmTitle),
          content: Text(l10n.moderationReturnToPendingConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.moderationReturnToPending),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busy = true);
    final ok = await ref
        .read(moderationHistoryProvider.notifier)
        .reopen(reportId: widget.report.id);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.moderationActionError)),
      );
      return;
    }
    ref.invalidate(moderationPendingReportsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    final launchName = resolveLaunchDisplayName(report.launchId);
    final statusLabel = switch (report.moderationStatus) {
      ConditionReportModerationStatus.approved =>
        l10n.moderationStatusFilterApproved,
      ConditionReportModerationStatus.rejected =>
        l10n.moderationStatusFilterRejected,
      ConditionReportModerationStatus.held => report.moderationStatus.name,
    };
    final reviewedAt = report.reviewedAt.toLocal();
    final reviewedTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(reviewedAt));
    final reviewedLabel =
        '${MaterialLocalizations.of(context).formatShortDate(reviewedAt)} · '
        '$reviewedTime';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(bottom: Spacing.xs),
                child: LinearProgressIndicator(),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    launchName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '${l10n.moderationReviewedAt}: $reviewedLabel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ModerationSubmitterField(
                    label: l10n.moderationSubmitterUid,
                    uid: report.submitterUid,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: report.reviewedBy != null
                      ? _ModerationSubmitterField(
                          label: l10n.moderationModeratorUid,
                          uid: report.reviewedBy!,
                        )
                      : _ModerationLabeledText(
                          label: l10n.moderationModeratorUid,
                          value: l10n.moderationSystemActor,
                        ),
                ),
              ],
            ),
            if (report.moderationReason != null) ...[
              const SizedBox(height: Spacing.sm),
              _ModerationLabeledText(
                label: l10n.moderationHoldReason,
                value: formatModerationReason(l10n, report.moderationReason!),
              ),
            ],
            const SizedBox(height: Spacing.sm),
            _ModerationMessageField(
              label: l10n.moderationMessage,
              message: report.message,
            ),
            const SizedBox(height: Spacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _busy ? null : _confirmReopen,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                ),
                child: Text(l10n.moderationReturnToPending),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle? _moderationFieldLabelStyle(BuildContext context) {
  return Theme.of(context).textTheme.labelMedium?.copyWith(
    fontWeight: FontWeight.bold,
  );
}

TextStyle? _moderationFieldValueStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.normal,
  );
}

class _ModerationLabeledText extends StatelessWidget {
  const _ModerationLabeledText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _moderationFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xxs),
        Text(value, style: _moderationFieldValueStyle(context)),
      ],
    );
  }
}

class _ModerationSubmitterField extends StatelessWidget {
  const _ModerationSubmitterField({
    required this.label,
    required this.uid,
  });

  final String label;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _moderationFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xxs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                truncateUid(uid),
                style: _moderationFieldValueStyle(context),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: uid));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.moderationUidCopied)),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxs),
                child: Icon(
                  Icons.copy,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModerationMessageField extends StatelessWidget {
  const _ModerationMessageField({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _moderationFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xxs),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
