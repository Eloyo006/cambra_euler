import 'package:cambra_euler/models/puzzle.dart';

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
