import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/content.dart';
import '../models/puzzle.dart';

const String storageKey = 'cambra_euler_state_v1';

/// S'injecta a `main()` amb un override.
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider sense override'),
);

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

class GameState {
  const GameState({
    this.progress = const {},
    this.hints = const {},
    this.elapsed = 0,
    this.penalty = 0,
    this.started = false,
    this.finished = false,
    this.bookOpened = false,
  });

  /// Passos resolts per puzle (id → nombre de passos encertats).
  final Map<String, int> progress;

  /// Pistes obertes per puzle (id → 0..3).
  final Map<String, int> hints;

  /// Temps real jugat, en segons.
  final int elapsed;

  /// Penalització acumulada per pistes, en segons.
  final int penalty;

  final bool started;
  final bool finished;

  /// Cert quan s'ha obert el llibre amagat de la Biblioteca.
  final bool bookOpened;

  /// Bonificació dels puzles opcionals resolts, en segons.
  int get bonus => puzzlesById.values
      .where((p) => p.optional && isSolved(p))
      .fold(0, (s, p) => s + p.bonus);

  /// Temps total: real + penalitzacions − bonificacions (mai negatiu).
  int get total => math.max(0, elapsed + penalty - bonus);

  /// El llibre apareix a la Biblioteca quan es resol el puzle 2.3.
  bool get bookAvailable => isSolved(puzzlesById[secretBookUnlockedBy]!);

  int stepsDone(Puzzle p) => progress[p.id] ?? 0;
  bool isSolved(Puzzle p) => stepsDone(p) >= p.steps.length;
  int hintsUsed(Puzzle p) => hints[p.id] ?? 0;

  /// Una sala està superada quan tots els puzles obligatoris ho estan.
  bool isRoomSolved(Room r) =>
      r.puzzles.where((p) => !p.optional).every(isSolved);
  bool get allRoomsSolved => rooms.every(isRoomSolved);

  /// Un puzle s'obre quan l'anterior de la sala està resolt.
  bool isUnlocked(Room r, Puzzle p) {
    final i = r.puzzles.indexOf(p);
    return i <= 0 || isSolved(r.puzzles[i - 1]);
  }

  int roomHints(Room r) => r.puzzles.fold(0, (s, p) => s + hintsUsed(p));
  int get totalHints => hints.values.fold(0, (s, h) => s + h);

  GameState copyWith({
    Map<String, int>? progress,
    Map<String, int>? hints,
    int? elapsed,
    int? penalty,
    bool? started,
    bool? finished,
    bool? bookOpened,
  }) => GameState(
    progress: progress ?? this.progress,
    hints: hints ?? this.hints,
    elapsed: elapsed ?? this.elapsed,
    penalty: penalty ?? this.penalty,
    started: started ?? this.started,
    finished: finished ?? this.finished,
    bookOpened: bookOpened ?? this.bookOpened,
  );

  Map<String, dynamic> toJson() => {
    'progress': progress,
    'hints': hints,
    'elapsed': elapsed,
    'penalty': penalty,
    'started': started,
    'finished': finished,
    'bookOpened': bookOpened,
  };

  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
    progress: Map<String, int>.from(j['progress'] as Map? ?? const {}),
    hints: Map<String, int>.from(j['hints'] as Map? ?? const {}),
    elapsed: j['elapsed'] as int? ?? 0,
    penalty: j['penalty'] as int? ?? 0,
    started: j['started'] as bool? ?? false,
    finished: j['finished'] as bool? ?? false,
    bookOpened: j['bookOpened'] as bool? ?? false,
  );
}

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;

  /// Cert mentre el jugador és dins del joc (no a la pantalla d'inici).
  bool _active = false;

  SharedPreferences get _prefs => ref.read(prefsProvider);

  @override
  GameState build() {
    ref.onDispose(() => _timer?.cancel());
    final raw = _prefs.getString(storageKey);
    if (raw == null) return const GameState();
    try {
      return GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Format desconegut: es comença de nou.
      return const GameState();
    }
  }

  void _save() => _prefs.setString(storageKey, jsonEncode(state.toJson()));

  /// Comença o continua la partida i posa en marxa el rellotge.
  void start() {
    _active = true;
    if (!state.started) {
      state = state.copyWith(started: true);
      _save();
    }
    resume();
  }

  void resume() {
    if (!_active || !state.started || state.finished || _timer != null) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// El jugador torna a la pantalla d'inici: el rellotge s'atura.
  void leave() {
    _active = false;
    pause();
  }

  /// Atura el rellotge (app en segon pla, pantalla d'inici…).
  void pause() {
    _timer?.cancel();
    _timer = null;
    _save();
  }

  void _tick() {
    state = state.copyWith(elapsed: state.elapsed + 1);
    if (state.elapsed % 5 == 0) _save();
  }

  /// Únic punt d'entrada per respondre. Retorna si la resposta és correcta.
  bool answer(Puzzle p, Object value) {
    if (state.finished || state.isSolved(p)) return false;
    final step = p.steps[state.stepsDone(p)];
    if (!step.check(value)) return false;

    final progress = {...state.progress, p.id: state.stepsDone(p) + 1};
    state = state.copyWith(progress: progress);
    if (p.id == finalPuzzle.id && state.isSolved(p)) {
      state = state.copyWith(finished: true);
      pause();
    }
    _save();
    return true;
  }

  /// Obre la pista següent del puzle i hi suma la penalització.
  void revealHint(Puzzle p) {
    final used = state.hintsUsed(p);
    if (used >= hintPenalties.length) return;
    state = state.copyWith(
      hints: {...state.hints, p.id: used + 1},
      penalty: state.penalty + hintPenalties[used],
    );
    _save();
  }

  /// Obre el llibre amagat (només si ja ha aparegut).
  void openBook() {
    if (state.bookOpened || !state.bookAvailable) return;
    state = state.copyWith(bookOpened: true);
    _save();
  }

  void reset() {
    leave();
    state = const GameState();
    _save();
  }
}
