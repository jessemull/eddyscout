import 'package:meta/meta.dart';

/// Immutable analytics event value type.
///
/// Event names must use snake_case.
/// Parameters must not contain PII (emails, phone numbers, names, etc.).
@immutable
class AnalyticsEvent {
  /// Creates an [AnalyticsEvent] with a [name] and optional [parameters].
  const AnalyticsEvent({required this.name, this.parameters = const {}});

  /// snake_case event name (e.g. "launch_point_viewed").
  final String name;

  /// Key-value parameters. Values must be String, int, double, or bool.
  final Map<String, Object> parameters;

  @override
  String toString() => 'AnalyticsEvent($name, $parameters)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsEvent &&
          other.name == name &&
          _mapEquals(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(parameters.entries));

  static bool _mapEquals(Map<String, Object> a, Map<String, Object> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
