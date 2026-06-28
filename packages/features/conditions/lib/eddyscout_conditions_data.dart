/// Data-layer implementations for app composition-root wiring.
///
/// Import only from `apps/eddyscout` — not from other feature packages.
library;

export 'src/data/conditions_service_provider.dart';
export 'src/data/firebase/conditions_callables.dart';
export 'src/data/firebase/conditions_summary_payload.dart';
export 'src/data/repositories/condition_report_moderation_repository_impl.dart';
export 'src/data/repositories/condition_report_submit_repository_impl.dart';
export 'src/data/repositories/condition_reports_repository_impl.dart';
export 'src/data/repositories/conditions_ai_summary_repository_impl.dart';
export 'src/data/repositories/go_no_go_profile_repository_impl.dart';
