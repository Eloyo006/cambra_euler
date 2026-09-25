import 'dart:convert';

import 'package:cambra_euler/core/theme.dart';
import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/screens/puzzle_screen.dart';
import 'package:cambra_euler/screens/room_screen.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpWith(
  WidgetTester tester,
  GameState state,
  Widget screen,
) async {
  SharedPreferences.setMockInitialValues({
    storageKey: jsonEncode(state.toJson()),
  });
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [prefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: buildTheme(), home: screen),
    ),
  );
  return container;
}

void main() {
  final library = rooms.firstWhere((r) => r.id == secretBookRoom);
  final unlocker = puzzlesById[secretBookUnlockedBy]!;

  testWidgets('sense resoldre el 2.3, el llibre no hi és', (tester) async {
    await pumpWith(tester, const GameState(), RoomScreen(room: library));
    expect(find.text(secretBookTitle), findsNothing);
  });

  testWidgets('amb el 2.3 resolt, el llibre brilla i es pot obrir', (
    tester,
  ) async {
    final c = await pumpWith(
      tester,
      GameState(progress: {unlocker.id: unlocker.steps.length}),
      RoomScreen(room: library),
    );
    expect(find.text(secretBookTitle), findsOneWidget);
    await tester.tap(find.text(secretBookTitle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(secretBookText), findsOneWidget);
    expect(c.read(gameProvider).bookOpened, isTrue);
  });

  testWidgets('la porta mostra el quadern només si s\'ha obert', (
    tester,
  ) async {
    await pumpWith(
      tester,
      const GameState(),
      const PuzzleScreen(puzzle: finalPuzzle),
    );
    expect(find.text(secretBookText), findsNothing);
    expect(find.text(secretBookMissing), findsOneWidget);

    await pumpWith(
      tester,
      GameState(
        progress: {unlocker.id: unlocker.steps.length},
        bookOpened: true,
      ),
      const PuzzleScreen(puzzle: finalPuzzle, key: ValueKey('obert')),
    );
    expect(find.text(secretBookText), findsOneWidget);
  });
}
