import 'package:flutter/painting.dart';

import '../core/modular.dart';
import '../core/set_expr.dart';

/// Un pas d'un puzle. Cada subclasse té dades immutables i un validador pur
/// [check], que no depèn de cap widget.
sealed class PuzzleStep {
  const PuzzleStep({required this.prompt, this.success});

  final String prompt;

  /// Missatge que es mostra quan el pas s'encerta.
  final String? success;

  bool check(Object answer);

  /// La resposta correcta, per mostrar-la un cop resolt el pas.
  String get solutionLabel;
}

// ───────────────────────────── Passos bàsics ─────────────────────────────

/// Resposta curta (normalment numèrica). Resposta: `String`.
class CodeStep extends PuzzleStep {
  const CodeStep({
    required super.prompt,
    required this.solution,
    super.success,
  });

  final String solution;

  @override
  bool check(Object answer) =>
      answer is String && normalizeCode(answer) == normalizeCode(solution);

  @override
  String get solutionLabel => solution;

  /// Treu espais i guions: «4 2 1 3» → «4213».
  static String normalizeCode(String s) =>
      s.replaceAll(RegExp(r'[\s\-_]'), '').toUpperCase();
}

/// Resposta de text lliure. Resposta: `String`.
class TextStep extends PuzzleStep {
  const TextStep({
    required super.prompt,
    required this.accepted,
    super.success,
  });

  /// Respostes acceptades. La primera és l'«oficial».
  final List<String> accepted;

  @override
  bool check(Object answer) =>
      answer is String &&
      accepted.any((a) => normalizeText(a) == normalizeText(answer));

  @override
  String get solutionLabel => accepted.first;

  /// Majúscules, sense accents (excepte la Ç) i amb els espais col·lapsats.
  static String normalizeText(String s) {
    const from = 'ÀÁÈÉÍÏÒÓÚÜ';
    const to = 'AAEEIIOOUU';
    final upper = s.toUpperCase().replaceAll('_', ' ');
    final buffer = StringBuffer();
    for (final ch in upper.split('')) {
      final i = from.indexOf(ch);
      buffer.write(i < 0 ? ch : to[i]);
    }
    return buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// Opció múltiple. Resposta: `int` (índex de l'opció).
class ChoiceStep extends PuzzleStep {
  const ChoiceStep({
    required super.prompt,
    required this.options,
    required this.correctIndex,
    super.success,
  });

  final List<String> options;
  final int correctIndex;

  @override
  bool check(Object answer) => answer is int && answer == correctIndex;

  @override
  String get solutionLabel => options[correctIndex];
}

// ───────────────────────────── Passos interactius ─────────────────────────────

/// Taula de multiplicar de ℤₙ amb la notació del professor ({1, …, n}, n ≡ 0).
/// Resposta: `List<int>` de n·n valors, fila per fila (fila i, columna j
/// corresponen a i+1 i j+1).
class TableStep extends PuzzleStep {
  const TableStep({
    required super.prompt,
    required this.modulus,
    required this.prefilled,
    super.success,
  });

  final int modulus;

  /// Índexs (fila·n + columna) de les caselles que ja venen escrites.
  final List<int> prefilled;

  int cell(int row, int col) => toProfNotation((row + 1) * (col + 1), modulus);

  List<int> get solution => [
    for (var r = 0; r < modulus; r++)
      for (var c = 0; c < modulus; c++) cell(r, c),
  ];

  @override
  bool check(Object answer) {
    if (answer is! List<int> || answer.length != modulus * modulus) {
      return false;
    }
    final s = solution;
    for (var i = 0; i < s.length; i++) {
      if (answer[i] != s[i]) return false;
    }
    return true;
  }

  @override
  String get solutionLabel => 'Taula de ℤ$modulus completa';
}

/// Diagrama de Venn de dos conjunts. Resposta: `List<int>` amb
/// [només A, A∩B, només B, fora].
class VennStep extends PuzzleStep {
  const VennStep({
    required super.prompt,
    required this.regions,
    this.labels = const ['Només A', 'A ∩ B', 'Només B', 'Fora'],
    super.success,
  });

  final List<int> regions;
  final List<String> labels;

  /// Quines regions de la resposta són correctes (per il·luminar-les).
  List<bool> correctRegions(List<int?> answer) => [
    for (var i = 0; i < regions.length; i++)
      i < answer.length && answer[i] == regions[i],
  ];

  @override
  bool check(Object answer) =>
      answer is List<int> &&
      answer.length == regions.length &&
      correctRegions(answer).every((ok) => ok);

  @override
  String get solutionLabel => [
    for (var i = 0; i < regions.length; i++) '${labels[i]}: ${regions[i]}',
  ].join(' · ');
}

/// Constructor d'expressions de conjunts. La validació és semàntica:
/// s'accepta qualsevol expressió equivalent a [target].
/// Resposta: `String` o `List<String>` de fitxes.
class ExpressionStep extends PuzzleStep {
  const ExpressionStep({
    required super.prompt,
    required this.target,
    required this.solution,
    this.tokens = const ['A′', 'B′', 'A', 'B', '∩', '∪', '(', ')'],
    super.success,
  });

  /// L'expressió que cal igualar, p. ex. «(A∪B)′».
  final String target;

  /// Una resposta correcta, per mostrar-la un cop resolt.
  final String solution;
  final List<String> tokens;

  @override
  bool check(Object answer) {
    final expr = switch (answer) {
      String s => s,
      List<String> l => l.join(),
      _ => null,
    };
    // Si l'alumne copia l'enunciat literalment, no val.
    if (expr == null || _compact(expr) == _compact(target)) return false;
    return setExprEquivalent(expr, target);
  }

  static String _compact(String s) => s.replaceAll(RegExp(r'\s'), '');

  @override
  String get solutionLabel => solution;
}

/// Repartir elements en caixes. Resposta: `List<Set<int>>` (una per caixa).
class PartitionStep extends PuzzleStep {
  const PartitionStep({
    required super.prompt,
    required this.items,
    required this.boxes,
    this.target,
    super.success,
  });

  final List<int> items;
  final int boxes;

  /// Si és `null`, val qualsevol partició en [boxes] parts no buides.
  /// Si no, cal exactament aquestes parts (en qualsevol ordre).
  final List<Set<int>>? target;

  static bool isPartition(List<Set<int>> parts, Iterable<int> of) {
    if (parts.any((p) => p.isEmpty)) return false;
    final seen = <int>{};
    for (final p in parts) {
      for (final x in p) {
        if (!seen.add(x)) return false; // repetit
      }
    }
    final all = of.toSet();
    return seen.length == all.length && seen.containsAll(all);
  }

  @override
  bool check(Object answer) {
    if (answer is! List<Set<int>> || answer.length != boxes) return false;
    if (!isPartition(answer, items)) return false;
    final t = target;
    if (t == null) return true;
    bool sameSet(Set<int> a, Set<int> b) =>
        a.length == b.length && a.containsAll(b);
    return t.every((part) => answer.any((box) => sameSet(box, part)));
  }

  @override
  String get solutionLabel {
    final t = target;
    if (t == null) return 'Partició en $boxes caixes';
    return t.map((s) => '{${(s.toList()..sort()).join(',')}}').join(', ');
  }
}

/// Ordenar línies. [lines] està en l'ordre correcte; [initialOrder] és
/// l'ordre desordenat (fix, no aleatori) en què es mostren.
/// Resposta: `List<int>` amb els índexs de [lines] en l'ordre de l'alumne.
class OrderStep extends PuzzleStep {
  const OrderStep({
    required super.prompt,
    required this.lines,
    required this.initialOrder,
    super.success,
  });

  final List<String> lines;
  final List<int> initialOrder;

  @override
  bool check(Object answer) {
    if (answer is! List<int> || answer.length != lines.length) return false;
    for (var i = 0; i < answer.length; i++) {
      if (answer[i] != i) return false;
    }
    return true;
  }

  @override
  String get solutionLabel => lines.join('\n');
}

/// Un moviment de Hanoi: d'una agulla a una altra (0, 1 o 2).
typedef HanoiMove = (int from, int to);

/// Torres de Hanoi amb 3 agulles. Cal passar tots els discos de l'agulla 0
/// a la 2 amb el mínim de moviments (2ⁿ − 1).
/// Resposta: `List<HanoiMove>`.
class HanoiStep extends PuzzleStep {
  const HanoiStep({required super.prompt, required this.discs, super.success});

  final int discs;

  int get minMoves => (1 << discs) - 1;

  /// Estat inicial: agulla 0 amb discos n..1 (el darrer és el de dalt).
  List<List<int>> get initial => [
    [for (var d = discs; d >= 1; d--) d],
    <int>[],
    <int>[],
  ];

  static bool isLegal(List<List<int>> pegs, HanoiMove m) {
    final (from, to) = m;
    if (from == to || from < 0 || from > 2 || to < 0 || to > 2) return false;
    if (pegs[from].isEmpty) return false;
    return pegs[to].isEmpty || pegs[to].last > pegs[from].last;
  }

  /// Aplica els moviments. Retorna `null` si n'hi ha algun d'il·legal.
  List<List<int>>? play(List<HanoiMove> moves) {
    final pegs = initial;
    for (final m in moves) {
      if (!isLegal(pegs, m)) return null;
      pegs[m.$2].add(pegs[m.$1].removeLast());
    }
    return pegs;
  }

  bool isDone(List<List<int>> pegs) => pegs[2].length == discs;

  @override
  bool check(Object answer) {
    if (answer is! List<HanoiMove> || answer.length != minMoves) return false;
    final pegs = play(answer);
    return pegs != null && isDone(pegs);
  }

  @override
  String get solutionLabel => '$discs discos en $minMoves moviments';
}

/// Tocar la línia on falla una prova. Resposta: `int` (índex de la línia).
class TapLineStep extends PuzzleStep {
  const TapLineStep({
    required super.prompt,
    required this.lines,
    required this.wrongLine,
    super.success,
  });

  final List<String> lines;
  final int wrongLine;

  @override
  bool check(Object answer) => answer is int && answer == wrongLine;

  @override
  String get solutionLabel => lines[wrongLine];
}

/// Pany de rodes. Totes les rodes comparteixen [symbols]; les de [locked]
/// venen fixades amb el valor de [solution]. Resposta: `List<String>`.
class WheelLockStep extends PuzzleStep {
  const WheelLockStep({
    required super.prompt,
    required this.symbols,
    required this.solution,
    this.locked = const [],
    super.success,
  });

  final List<String> symbols;
  final List<String> solution;

  /// Posicions (0-based) de les rodes bloquejades.
  final List<int> locked;

  @override
  bool check(Object answer) {
    if (answer is! List<String> || answer.length != solution.length) {
      return false;
    }
    for (var i = 0; i < solution.length; i++) {
      if (answer[i] != solution[i]) return false;
    }
    return true;
  }

  @override
  String get solutionLabel => solution.join(' ');
}

// ───────────────────────────── Puzles i sales ─────────────────────────────

class Puzzle {
  const Puzzle({
    required this.id,
    required this.title,
    required this.source,
    required this.statement,
    required this.steps,
    required this.hints,
    this.theory,
    this.outro,
  });

  final String id;
  final String title;

  /// Origen: apunts FOMA o número d'exercici de la llista.
  final String source;
  final String statement;
  final List<PuzzleStep> steps;

  /// Tres nivells: «Suggeriment», «Teoria», «Gairebé la solució».
  final List<String> hints;

  /// Targeta de teoria opcional (sempre visible, sense penalització).
  final String? theory;

  /// Text que es mostra quan el puzle queda resolt.
  final String? outro;
}

class Room {
  const Room({
    required this.id,
    required this.number,
    required this.name,
    required this.topic,
    required this.color,
    required this.intro,
    required this.digit,
    required this.digitPosition,
    required this.puzzles,
  });

  final String id;
  final int number;
  final String name;
  final String topic;
  final Color color;
  final String intro;

  /// Xifra del pany «a 3 c 5 4» que dona la sala, i la seva posició (1–5).
  final int digit;
  final int digitPosition;

  final List<Puzzle> puzzles;
}
