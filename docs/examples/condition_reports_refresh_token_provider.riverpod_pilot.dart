// Reference @riverpod pilot (not part of any package).
//
// Copy into `packages/features/conditions/lib/src/domain/condition_reports_refresh_token_provider.dart`
// after a workspace-wide `flutter_riverpod` 3.x upgrade. See `docs/CODEGEN.md`.

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'condition_reports_refresh_token_provider.g.dart';

@riverpod
class ConditionReportsRefreshToken extends _$ConditionReportsRefreshToken {
  @override
  int build() => 0;

  void increment() => state++;
}
