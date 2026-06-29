import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/src/presentation/map_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('MapBrowseSearchField updates browse search query', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: const Scaffold(
            body: MapBrowseSearchField(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('map_browse_search_field')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'sellwood');
    await tester.pump();

    expect(container.read(mapSearchQueryProvider), 'sellwood');
    expect(
      container.read(mapSearchContextStateProvider),
      MapSearchContext.browse,
    );
  });
}
