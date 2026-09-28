// ignore_for_file: invalid_use_of_visible_for_testing_member
// Captures de les variants de la Sala 3 (proves per ordenar i proves falses)
// a 360 dp, per revisar-les a ull. Falla si algun text desborda.
//
// Ús (Windows, des de l'arrel del projecte):
//   flutter test tool/screenshots/variants_test.dart --update-goldens
//
// Les imatges queden a build/variants/ (fora del control de versions).
import 'dart:convert';

import 'package:cambra_euler/core/theme.dart';
import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/screens/puzzle_screen.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/helpers.dart';
import 'screenshots_test.dart' show flutterFonts, loadFont, windowsFonts;

/// Una llavor on el puzle [id] té el títol [title].
int seedFor(String id, String title) {
  for (var s = 0; s < 5000; s++) {
    if (GameContent.forSeed(s).puzzlesById[id]!.title == title) return s;
  }
  throw StateError('Cap llavor amb $id = $title');
}

Future<void> shootStep(
  WidgetTester tester,
  String name,
  int seed,
  String id,
  int step,
) async {
  // Alta, perquè s'hi vegi la prova sencera.
  tester.view.physicalSize = const Size(360 * 2.5, 1500 * 2.5);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  final state = GameState(seed: seed, started: true, progress: {id: step});
  SharedPreferences.setMockInitialValues({
    storageKey: jsonEncode(state.toJson()),
  });
  final prefs = await SharedPreferences.getInstance();
  final content = GameContent.forSeed(seed);
  final room = content.rooms.firstWhere(
    (r) => r.puzzles.any((p) => p.id == id),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...testOverrides(prefs),
        newSeedProvider.overrideWithValue(() => seed),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Symbols', 'SegoeUI'],
        ),
        home: DefaultTextStyle.merge(
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontFamilyFallback: ['Symbols', 'SegoeUI'],
          ),
          child: PuzzleScreen(puzzle: content.puzzlesById[id]!, room: room),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
  // Cap text desbordat ni cap error de dibuix.
  expect(tester.takeException(), isNull, reason: name);
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../build/variants/$name.png'),
  );
}

void main() {
  setUpAll(() async {
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
    // Com a Android, un segon respatller amb més símbols (ᵏ, ⁽ ⁾…).
    await loadFont('SegoeUI', ['$windowsFonts\\segoeui.ttf']);
  });

  const proves = {
    'senars': 'La suma dels senars',
    'gauss': 'La suma de Gauss',
    'cubs': 'Els cubs i el 3',
  };
  proves.forEach((key, title) {
    for (var step = 0; step < 3; step++) {
      testWidgets('3.1 $key · pas $step', (t) async {
        await shootStep(
          t,
          '31_${key}_$step',
          seedFor('3.1', title),
          '3.1',
          step,
        );
      });
    }
  });

  const falses = {
    'sense_base': 'La fitxa que no cau',
    'quadrats': 'Quadrats i potències',
  };
  falses.forEach((key, title) {
    for (var step = 0; step < 2; step++) {
      testWidgets('3.3 $key · pas $step', (t) async {
        await shootStep(
          t,
          '33_${key}_$step',
          seedFor('3.3', title),
          '3.3',
          step,
        );
      });
    }
  });
}
