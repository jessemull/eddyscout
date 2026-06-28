import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'moderation_selection_provider.g.dart';

/// Selected pending report ids for bulk moderation actions.
@riverpod
class ModerationSelection extends _$ModerationSelection {
  @override
  Set<String> build() => {};

  /// Toggles one report id in the selection set.
  void toggle(String reportId) {
    final next = Set<String>.from(state);
    if (next.contains(reportId)) {
      next.remove(reportId);
    } else {
      next.add(reportId);
    }
    state = next;
  }

  /// Selects all provided report ids.
  void selectAll(Iterable<String> reportIds) {
    state = reportIds.toSet();
  }

  /// Clears the current selection.
  void clear() {
    state = {};
  }

  /// Removes ids that are no longer visible in the queue.
  void retainOnly(Iterable<String> visibleReportIds) {
    final visible = visibleReportIds.toSet();
    state = state.where(visible.contains).toSet();
  }
}
