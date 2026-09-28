import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/models/puzzle.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Llavor fixa dels tests: les partides noves i els `GameState()` la fan
/// servir, així el contingut no depèn de l'atzar.
const testSeed = pdfSeed;

/// Contingut de la partida dels tests.
final testContent = GameContent.forSeed(testSeed);
List<Room> get rooms => testContent.rooms;
Puzzle get finalPuzzle => testContent.finalPuzzle;
Map<String, Puzzle> get puzzlesById => testContent.puzzlesById;
String get secretBookText => testContent.secretBookText;

/// Overrides comuns: preferències de prova i llavor fixa.
List<Override> testOverrides(SharedPreferences prefs) => [
  prefsProvider.overrideWithValue(prefs),
  newSeedProvider.overrideWithValue(() => testSeed),
];

/// Solució òptima de Hanoi (2ⁿ − 1 moviments) de [from] a [to].
List<HanoiMove> hanoiSolution(int n, [int from = 0, int to = 2, int via = 1]) {
  if (n == 0) return [];
  return [
    ...hanoiSolution(n - 1, from, via, to),
    (from, to),
    ...hanoiSolution(n - 1, via, to, from),
  ];
}

/// Una resposta correcta per a qualsevol pas, en el format que espera `check`.
Object solutionOf(PuzzleStep step) => switch (step) {
  CodeStep s => s.solution,
  TextStep s => s.accepted.first,
  ChoiceStep s => s.correctIndex,
  TableStep s => s.expectedAnswer,
  VennStep s => s.regions,
  ExpressionStep s => s.solution,
  PartitionStep s =>
    s.target ??
        [
          for (var i = 0; i < s.boxes - 1; i++) {s.items[i]},
          s.items.sublist(s.boxes - 1).toSet(),
        ],
  OrderStep s => [for (var i = 0; i < s.lines.length; i++) i],
  HanoiStep s => hanoiSolution(s.discs),
  TapLineStep s => s.wrongLine,
  WheelLockStep s => s.solution ?? WheelLockStep.noSolution,
};
