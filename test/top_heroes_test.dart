import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviewebapp/app/models/popular_actors_model.dart';
import 'package:moviewebapp/app/providers/people_provider.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/top_heroes.dart';
import 'package:provider/provider.dart';

class _FakePeopleProvider extends PeopleProvider {
  final List<String?> requests = [];
  bool fail = false;

  @override
  Future<PeoplePage> fetchPopularPeoplePage({
    String? cursorAfter,
    bool actingOnly = false,
  }) async {
    expect(actingOnly, isTrue);
    requests.add(cursorAfter);
    if (fail) throw StateError('Test failure');
    final start = cursorAfter == null ? 0 : 8;
    return (
      actors: List.generate(
        cursorAfter == null ? 8 : 4,
        (index) =>
            Actors(id: start + index + 1, name: 'Actor ${start + index + 1}'),
      ),
      nextCursor: cursorAfter == null ? 'next' : null,
    );
  }
}

void main() {
  Future<void> showWidget(
    WidgetTester tester,
    _FakePeopleProvider provider,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider<PeopleProvider>.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: TopHeroes())),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows four actors and loads more when advancing', (
    tester,
  ) async {
    final provider = _FakePeopleProvider();
    await showWidget(tester, provider);

    expect(find.text('Top HollyWood Actors'), findsOneWidget);
    expect(find.text('Actor 1'), findsOneWidget);
    expect(find.text('Actor 4'), findsOneWidget);
    expect(provider.requests, [null]);

    await tester.tap(find.byTooltip('Next actors'));
    await tester.pumpAndSettle();
    expect(find.text('Actor 5'), findsOneWidget);
    expect(provider.requests, [null, 'next']);

    await tester.tap(find.byTooltip('Next actors'));
    await tester.pumpAndSettle();
    expect(find.text('Actor 9'), findsOneWidget);
  });

  testWidgets('offers retry when actor loading fails', (tester) async {
    final provider = _FakePeopleProvider()..fail = true;
    await showWidget(tester, provider);
    expect(find.text('Unable to load actors.'), findsOneWidget);

    provider.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Actor 1'), findsOneWidget);
    expect(provider.requests, [null, null]);
  });

  testWidgets('shows four cards in two rows on mobile', (tester) async {
    final provider = _FakePeopleProvider();
    await showWidget(tester, provider);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();

    expect(find.text('Actor 1'), findsOneWidget);
    expect(find.text('Actor 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
