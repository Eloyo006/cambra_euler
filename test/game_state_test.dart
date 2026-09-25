import 'dart:convert';

import 'package:cambra_euler/data/content.dart';
import 'helpers.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer([
  Map<String, Object> init = const {},
]) async {
  SharedPreferences.setMockInitialValues(init);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [prefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('una resposta incorrecta no avança', () async {
    final c = await makeContainer();
    final game = c.read(gameProvider.notifier);
    expect(game.answer(rooms[0].puzzles[0], '35'), isFalse);
    expect(c.read(gameProvider).stepsDone(rooms[0].puzzles[0]), 0);
  });

  test('partida completa fins a la victòria', () async {
    final c = await makeContainer();
    final game = c.read(gameProvider.notifier)..start();
    for (final r in rooms) {
      for (final p in r.puzzles) {
        for (final s in p.steps) {
          expect(game.answer(p, solutionOf(s)), isTrue, reason: p.id);
        }
      }
      expect(c.read(gameProvider).isRoomSolved(r), isTrue);
    }
    expect(c.read(gameProvider).allRoomsSolved, isTrue);
    for (final s in finalPuzzle.steps) {
      expect(game.answer(finalPuzzle, solutionOf(s)), isTrue);
    }
    expect(c.read(gameProvider).finished, isTrue);
  });

  test('pistes: +30, +60, +120 s i com a màxim 3', () async {
    final c = await makeContainer();
    final game = c.read(gameProvider.notifier);
    final p = rooms[1].puzzles[0];
    for (var i = 0; i < 4; i++) {
      game.revealHint(p);
    }
    final s = c.read(gameProvider);
    expect(s.hintsUsed(p), 3);
    expect(s.penalty, 210);
    expect(s.total, 210);
  });

  test('el progrés es desa i es recupera', () async {
    final c = await makeContainer();
    final game = c.read(gameProvider.notifier)..start();
    game.answer(rooms[0].puzzles[0], '36');
    game.revealHint(rooms[0].puzzles[0]);
    game.leave();

    final prefs = c.read(prefsProvider);
    final raw = prefs.getString(storageKey)!;
    final c2 = await makeContainer({storageKey: raw});
    final s = c2.read(gameProvider);
    expect(s.started, isTrue);
    expect(s.stepsDone(rooms[0].puzzles[0]), 1);
    expect(s.penalty, 30);
    expect(jsonDecode(raw), isA<Map<String, dynamic>>());
  });

  test('dades corruptes → partida nova', () async {
    final c = await makeContainer({storageKey: '{no json'});
    expect(c.read(gameProvider).started, isFalse);
  });

  test('els puzles es desbloquegen en ordre', () async {
    final c = await makeContainer();
    final r = rooms[0];
    final s = c.read(gameProvider);
    expect(s.isUnlocked(r, r.puzzles[0]), isTrue);
    expect(s.isUnlocked(r, r.puzzles[1]), isFalse);
  });
}
