// ignore_for_file: invalid_use_of_visible_for_testing_member
// Genera les captures de pantalla de docs/img/ sense emulador, renderitzant
// les pantalles reals amb les fonts reals (Roboto + símbols).
//
// Ús (Windows, des de l'arrel del projecte):
//   flutter test tool/screenshots/screenshots_test.dart --update-goldens
//
// No forma part de `flutter test` (és fora de test/) perquè depèn de fonts
// del sistema.
import 'dart:convert';
import 'dart:io';

import 'package:cambra_euler/core/theme.dart';
import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/screens/home_screen.dart';
import 'package:cambra_euler/screens/map_screen.dart';
import 'package:cambra_euler/screens/puzzle_screen.dart';
import 'package:cambra_euler/screens/room_screen.dart';
import 'package:cambra_euler/screens/victory_screen.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:cambra_euler/state/ranking.dart';
import 'package:flutter/material.dart';
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

ThemeData screenshotTheme() =>
    buildTheme(fontFamily: 'Roboto', fontFamilyFallback: const ['Symbols']);

/// Progrés amb els puzles indicats resolts.
Map<String, int> solved(Iterable<String> ids) => {
  for (final id in ids) id: puzzlesById[id]!.steps.length,
};

Future<void> shoot(
  WidgetTester tester,
  String name,
  GameState state,
  Widget screen, {
  Future<void> Function()? interact,
  List<RankEntry> ranking = const [],
}) async {
  tester.view.physicalSize = const Size(360 * 2.5, 760 * 2.5);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    storageKey: jsonEncode(state.toJson()),
    rankingKey: jsonEncode([for (final e in ranking) e.toJson()]),
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: screenshotTheme(),
        home: DefaultTextStyle.merge(
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontFamilyFallback: ['Symbols'],
          ),
          child: screen,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 3));
  if (interact != null) await interact();
  await tester.pump(const Duration(seconds: 3));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/img/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    // Text sense família explícita (CustomPaint, botons): al mòbil és Roboto;
    // als tests és «FlutterTest», així que hi carreguem Roboto.
    await loadFont('FlutterTest', ['$flutterFonts\\roboto-medium.ttf']);
    await loadFont('Roboto', [
      '$flutterFonts\\roboto-regular.ttf',
      '$flutterFonts\\roboto-medium.ttf',
      '$flutterFonts\\roboto-bold.ttf',
      '$flutterFonts\\roboto-italic.ttf',
    ]);
    await loadFont('MaterialIcons', [
      '$flutterFonts\\materialicons-regular.otf',
    ]);
    await loadFont('Symbols', ['$windowsFonts\\seguisym.ttf']);
  });

  final s1 = rooms[0], s2 = rooms[1], s3 = rooms[2];

  testWidgets('01 inici', (t) async {
    await shoot(t, '01_inici', const GameState(), const HomeScreen());
  });

  testWidgets('02 vestibul', (t) async {
    await shoot(
      t,
      '02_vestibul',
      GameState(
        started: true,
        elapsed: 754,
        penalty: 90,
        progress: solved([...s1.puzzles.map((p) => p.id), '2.1', '2.2']),
      ),
      const MapScreen(),
    );
  });

  testWidgets('03 venn', (t) async {
    await shoot(
      t,
      '03_venn',
      const GameState(started: true),
      PuzzleScreen(puzzle: s1.puzzles[0], room: s1),
      interact: () async {
        for (final (label, v) in [('Només A', 18), ('A ∩ B', 7)]) {
          await t.tap(find.text('$label: ?'));
          await t.pumpAndSettle();
          await t.enterText(find.byType(TextField), '$v');
          await t.tap(find.text("D'acord"));
          await t.pumpAndSettle();
        }
      },
    );
  });

  testWidgets('04 prestatgeria', (t) async {
    await shoot(
      t,
      '04_prestatgeria',
      GameState(
        started: true,
        progress: {
          ...solved(['1.1', '1.2']),
          '1.3': 2,
        },
      ),
      PuzzleScreen(puzzle: s1.puzzles[2], room: s1),
      interact: () async {
        await t.scrollUntilVisible(find.text('Prestatge'), 200);
        for (final (book, box) in [(3, 1), (6, 1), (1, 2)]) {
          await t.tap(
            find.byWidgetPredicate(
              (w) => w is Draggable<int> && w.data == book,
            ),
          );
          await t.pump();
          await t.tap(find.text('Caixa $box'));
          await t.pump();
        }
      },
    );
  });

  testWidgets('05 taula', (t) async {
    await shoot(
      t,
      '05_taula_mod5',
      GameState(started: true, progress: solved(s1.puzzles.map((p) => p.id))),
      PuzzleScreen(puzzle: s2.puzzles[0], room: s2),
      interact: () async {
        await t.scrollUntilVisible(find.text('Comprova'), 200);
      },
    );
  });

  testWidgets('06 cesar', (t) async {
    await shoot(
      t,
      '06_roda_cesar',
      GameState(
        started: true,
        progress: solved([...s1.puzzles.map((p) => p.id), '2.1', '2.2']),
      ),
      PuzzleScreen(puzzle: s2.puzzles[2], room: s2),
      interact: () async {
        await t.scrollUntilVisible(
          find.byTooltip('Gira el disc interior endavant'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        for (var i = 0; i < 3; i++) {
          await t.tap(find.byTooltip('Gira el disc interior endavant'));
          await t.pump();
        }
      },
    );
  });

  testWidgets('07 hanoi', (t) async {
    await shoot(
      t,
      '07_hanoi',
      GameState(
        started: true,
        progress: solved([
          ...s1.puzzles.map((p) => p.id),
          ...s2.puzzles.map((p) => p.id),
          '3.1',
        ]),
      ),
      PuzzleScreen(puzzle: s3.puzzles[1], room: s3),
      interact: () async {
        final pegs = find.bySemanticsLabel(RegExp('^Agulla'));
        await t.scrollUntilVisible(pegs.first, 200);
        for (final (a, b) in [(0, 2), (0, 1), (2, 1)]) {
          await t.tap(pegs.at(a));
          await t.pump();
          await t.tap(pegs.at(b));
          await t.pump();
        }
      },
    );
  });

  testWidgets('08 biblioteca amb el llibre', (t) async {
    await shoot(
      t,
      '08_llibre_amagat',
      GameState(
        started: true,
        progress: solved([
          ...s1.puzzles.map((p) => p.id),
          ...s2.puzzles.map((p) => p.id),
        ]),
      ),
      RoomScreen(room: s1),
    );
  });

  testWidgets('09 porta', (t) async {
    await shoot(
      t,
      '09_porta',
      GameState(
        started: true,
        bookOpened: true,
        progress: {
          ...solved(rooms.expand((r) => r.puzzles).map((p) => p.id)),
          finalPuzzle.id: 2,
        },
      ),
      const PuzzleScreen(puzzle: finalPuzzle),
      interact: () async {
        await t.drag(find.byType(ListView).first, const Offset(0, -330));
      },
    );
  });

  testWidgets('10 victoria', (t) async {
    const now = '2026-09-25T18:30:00';
    await shoot(
      t,
      '10_victoria',
      GameState(
        started: true,
        finished: true,
        finishedAt: now,
        elapsed: 1384,
        penalty: 210,
        hints: const {'2.1': 2, '3.2': 1, 'porta': 1},
        progress: {
          ...solved(rooms.expand((r) => r.puzzles).map((p) => p.id)),
          finalPuzzle.id: finalPuzzle.steps.length,
        },
      ),
      const VictoryScreen(),
      ranking: const [
        RankEntry(
          total: 1102,
          elapsed: 1102,
          penalty: 0,
          hints: 0,
          finishedAt: '2026-09-24T11:00:00',
        ),
        RankEntry(
          total: 1534,
          elapsed: 1384,
          penalty: 210,
          hints: 4,
          finishedAt: now,
        ),
      ],
    );
  });
}
