// ignore_for_file: invalid_use_of_visible_for_testing_member
// Comprova que, a 360 dp i amb el rellotge al màxim (99:59), cap títol de la
// barra superior queda tallat. Fa servir les fonts reals (Roboto + símbols).
//
// Ús (Windows, des de l'arrel del projecte):
//   flutter test tool/layout/layout_test.dart
//
// No forma part de `flutter test` (és fora de test/) perquè depèn de fonts
// del sistema.
import 'dart:convert';
import 'dart:io';

import 'package:cambra_euler/core/theme.dart';
import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/screens/puzzle_screen.dart';
import 'package:cambra_euler/screens/room_screen.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const flutterFonts = r'C:\flutter\bin\cache\artifacts\material_fonts';
const windowsFonts = r'C:\Windows\Fonts';

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File(f).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// Temps llargs perquè el rellotge ocupi l'amplada màxima (99:59).
final _state = GameState(
  started: true,
  elapsed: 5999,
  puzzleTimes: {for (final id in puzzlesById.keys) id: 5999},
);

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    storageKey: jsonEncode(_state.toJson()),
  });
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [prefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildTheme(
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Symbols'],
        ),
        home: screen,
      ),
    ),
  );
}

/// El títol de la barra superior es veu sencer (no queda tallat amb «…»).
void _expectTitleFits(WidgetTester tester, String title) {
  final finder = find.descendant(
    of: find.byType(AppBar),
    matching: find.text(title),
  );
  expect(finder, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(paragraph.didExceedMaxLines, isFalse, reason: title);
  expect(tester.takeException(), isNull, reason: title);
}

void main() {
  setUpAll(() async {
    await loadFont('Roboto', [
      '$flutterFonts\\roboto-regular.ttf',
      '$flutterFonts\\roboto-medium.ttf',
      '$flutterFonts\\roboto-bold.ttf',
    ]);
    await loadFont('MaterialIcons', [
      '$flutterFonts\\materialicons-regular.otf',
    ]);
    await loadFont('Symbols', ['$windowsFonts\\seguisym.ttf']);
  });

  for (final p in puzzlesById.values) {
    testWidgets('a 360 dp, el títol «${p.title}» cap amb el rellotge', (
      tester,
    ) async {
      final room = rooms.where((r) => r.puzzles.contains(p)).firstOrNull;
      await _pump(tester, PuzzleScreen(puzzle: p, room: room));
      _expectTitleFits(tester, p.title);
    });
  }

  for (final r in rooms) {
    testWidgets('a 360 dp, el títol «${r.name}» cap amb el rellotge', (
      tester,
    ) async {
      await _pump(tester, RoomScreen(room: r));
      _expectTitleFits(tester, r.name);
    });
  }
}
