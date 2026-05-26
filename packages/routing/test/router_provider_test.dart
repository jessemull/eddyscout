import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('createRouter wires routes and initialLocation', () {
    final router = createRouter(
      initialLocation: '/a',
      routes: [
        GoRoute(path: '/a', builder: (_, state) => const SizedBox()),
        GoRoute(path: '/b', builder: (_, state) => const SizedBox()),
      ],
    );

    expect(router.configuration.routes, hasLength(2));
    expect(router.routeInformationProvider.value.uri.path, '/a');
  });

  testWidgets('createRouter uses redirect callback', (tester) async {
    final router = createRouter(
      routes: [
        GoRoute(path: '/', builder: (_, state) => const SizedBox()),
        GoRoute(path: '/x', builder: (_, state) => const SizedBox()),
      ],
      redirect: (context, state) {
        if (state.uri.path == '/x') {
          return '/';
        }
        return null;
      },
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Router.withConfig(config: router),
      ),
    );
    router.go('/x');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/');
  });
}
