import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Logs screen views when navigation occurs.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  /// Creates an observer that forwards screen views to the analytics client.
  AnalyticsNavigatorObserver(this._client);

  final AnalyticsClient _client;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logScreen(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logScreen(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logScreen(newRoute);
  }

  void _logScreen(Route<dynamic>? route) {
    if (route == null) {
      return;
    }
    final context = route.navigator?.context;
    if (context == null || !context.mounted) {
      return;
    }
    final matchedLocation = GoRouter.of(context).state.matchedLocation;
    final screenName = AnalyticsScreenNames.fromMatchedLocation(
      matchedLocation,
    );
    if (screenName == null) {
      return;
    }
    unawaited(_client.logScreenView(screenName: screenName));
  }
}
