// Reference @riverpod pilot (not part of any package — copy into conditions when
// riverpod_generator aligns with the workspace source_gen 4.2 override).
//
// See docs/CODEGEN.md § Riverpod codegen pilot.

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'condition_reports_refresh_token_provider.g.dart';

@riverpod
class ConditionReportsRefreshToken extends _$ConditionReportsRefreshToken {
  @override
  int build() => 0;

  void increment() => state++;
}
