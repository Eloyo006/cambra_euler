import 'dart:convert';

import 'package:cambra_euler/data/content.dart';
import 'helpers.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:cambra_euler/state/ranking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer([
  Map<String, Object> init = const {},
]) async {
  SharedPreferences.setMockInitialValues(init);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: testOverrides(prefs));
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
    // La partida queda al rànquing.
    final ranking = c.read(rankingProvider);
    expect(ranking, hasLength(1));
    expect(ranking.single.finishedAt, c.read(gameProvider).finishedAt);
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
    final p11 = rooms[0].puzzles[0];
    game.answer(p11, solutionOf(p11.steps[0]));
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

  test('el llibre amagat: apareix amb el 2.3 i es recorda obert', () async {
    final c = await makeContainer();
    final game = c.read(gameProvider.notifier);
    final p23 = puzzlesById[secretBookUnlockedBy]!;
    game.openBook();
    expect(c.read(gameProvider).bookOpened, isFalse); // encara no hi és
    for (final s in p23.steps) {
      game.answer(p23, solutionOf(s));
    }
    expect(c.read(gameProvider).bookAvailable, isTrue);
    game.openBook();
    expect(c.read(gameProvider).bookOpened, isTrue);

    final raw = c.read(prefsProvider).getString(storageKey)!;
    final c2 = await makeContainer({storageKey: raw});
    expect(c2.read(gameProvider).bookOpened, isTrue);
  });

  test('el bonus opcional resta 60 s i la sala no el necessita', () async {
    final room = rooms.firstWhere((r) => r.id == 'sala3');
    final required = {
      for (final pz in room.puzzles.where((pz) => !pz.optional))
        pz.id: pz.steps.length,
    };
    final c = await makeContainer({
      storageKey: jsonEncode(
        GameState(progress: required, elapsed: 500).toJson(),
      ),
    });
    expect(c.read(gameProvider).isRoomSolved(room), isTrue);
    expect(c.read(gameProvider).total, 500);

    final game = c.read(gameProvider.notifier);
    final bonus = puzzlesById['3.4']!;
    for (final s in bonus.steps) {
      expect(game.answer(bonus, solutionOf(s)), isTrue);
    }
    expect(c.read(gameProvider).bonus, 60);
    expect(c.read(gameProvider).total, 440);
  });

  group('temps per enigma', () {
    final p = rooms[0].puzzles[0];

    test('només compta mentre el puzle és obert', () async {
      final c = await makeContainer();
      final game = c.read(gameProvider.notifier);
      game.tick(); // al vestíbul
      game.enterPuzzle(p);
      game
        ..tick()
        ..tick();
      game.exitPuzzle(p);
      game.tick();
      final s = c.read(gameProvider);
      expect(s.elapsed, 4);
      expect(s.puzzleTime(p), 2);
    });

    test("s'acumula entre visites i inclou les pistes", () async {
      final c = await makeContainer();
      final game = c.read(gameProvider.notifier);
      game
        ..enterPuzzle(p)
        ..tick()
        ..exitPuzzle(p)
        ..enterPuzzle(p)
        ..tick()
        ..revealHint(p)
        ..revealHint(p);
      expect(c.read(gameProvider).puzzleTime(p), 2 + 30 + 60);
    });

    test('es congela quan el puzle es resol', () async {
      final c = await makeContainer();
      final game = c.read(gameProvider.notifier)..enterPuzzle(p);
      game.tick();
      for (final step in p.steps) {
        expect(game.answer(p, solutionOf(step)), isTrue);
      }
      game
        ..tick()
        ..tick();
      final s = c.read(gameProvider);
      expect(s.puzzleTime(p), 1);
      expect(s.elapsed, 3);
    });

    test('es desa i es recupera', () async {
      final c = await makeContainer();
      c.read(gameProvider.notifier)
        ..enterPuzzle(p)
        ..tick()
        ..pause();
      final raw = c.read(prefsProvider).getString(storageKey)!;
      final c2 = await makeContainer({storageKey: raw});
      expect(c2.read(gameProvider).puzzleTime(p), 1);
    });

    test('una partida desada sense el camp es carrega igual', () async {
      final old = jsonEncode({'elapsed': 90, 'penalty': 30});
      final c = await makeContainer({storageKey: old});
      final s = c.read(gameProvider);
      expect(s.elapsed, 90);
      expect(s.puzzleTimes, isEmpty);
      expect(s.puzzleTime(p), 0);
    });
  });

  group('llavor de la partida', () {
    test('una partida nova fa servir la llavor del proveïdor', () async {
      final c = await makeContainer();
      expect(c.read(gameProvider).seed, testSeed);
      expect(c.read(gameProvider).content.seed, testSeed);
    });

    test('la llavor es desa i es recupera', () async {
      final saved = jsonEncode(const GameState(seed: 777).toJson());
      final c = await makeContainer({storageKey: saved});
      expect(c.read(gameProvider).seed, 777);
      c.read(gameProvider.notifier).start();
      c.read(gameProvider.notifier).pause();
      final raw = c.read(prefsProvider).getString(storageKey)!;
      expect(jsonDecode(raw)['seed'], 777);
    });

    test('una partida desada sense llavor fa servir la 0', () async {
      final old = jsonEncode({'elapsed': 90});
      final c = await makeContainer({storageKey: old});
      expect(c.read(gameProvider).seed, 0);
    });

    test('«Nova partida» tria una llavor nova', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      var next = 10;
      final c = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          newSeedProvider.overrideWithValue(() => next++),
        ],
      );
      addTearDown(c.dispose);
      expect(c.read(gameProvider).seed, 10);
      c.read(gameProvider.notifier).reset();
      expect(c.read(gameProvider).seed, 11);
    });

    test('copyWith conserva la llavor', () {
      const s = GameState(seed: 5);
      expect(s.copyWith(elapsed: 3).seed, 5);
    });
  });

  test('el temps total no és mai negatiu', () {
    final s = GameState(progress: {'3.4': puzzlesById['3.4']!.steps.length});
    expect(s.bonus, 60);
    expect(s.total, 0);
  });
}
