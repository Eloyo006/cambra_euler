import 'package:flutter/painting.dart';

import '../core/modular.dart';
import '../core/set_expr.dart';

/// Animacions que es poden mostrar en resoldre un pas.
enum Celebration {
  none,

  /// Una fila de dòminos que cauen (3.1).
  dominoes,

  /// Els grups {c₁} i {c₂} disjunts del pas k = 1 → 2 (3.3).
  disjointHorses,
}

/// Un pas d'un puzle. Cada subclasse té dades immutables i un validador pur
/// [check], que no depèn de cap widget.
sealed class PuzzleStep {
  const PuzzleStep({
    required this.prompt,
    this.success,
    this.celebration = Celebration.none,
  });

  final String prompt;

  /// Missatge que es mostra quan el pas s'encerta.
  final String? success;

  /// Animació que acompanya el pas un cop resolt.
  final Celebration celebration;

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

/// Ajuda visual que acompanya un [TextStep].
enum StepAid {
  none,

  /// Roda de César: dos discos concèntrics amb l'alfabet de 27 lletres.
  caesarWheel,

  /// Taula x → 2x + 3 (mod 27) per al xifrat afí.
  affineTable,
}

/// Resposta de text lliure. Resposta: `String`.
class TextStep extends PuzzleStep {
  const TextStep({
    required super.prompt,
    required this.accepted,
    this.aid = StepAid.none,
    this.aidMinHints = 0,
    this.affine = (a: 2, b: 3),
    super.success,
  });

  /// Respostes acceptades. La primera és l'«oficial».
  final List<String> accepted;

  final StepAid aid;

  /// Clau e(x) = a·x + b de la taula d'ajuda [StepAid.affineTable].
  final ({int a, int b}) affine;

  /// Pistes que cal haver obert perquè es vegi l'ajuda (0 = sempre).
  final int aidMinHints;

  bool showsAid(int hintsUsed) =>
      aid != StepAid.none && hintsUsed >= aidMinHints;

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
    this.mode = TableMode.fill,
    this.prefilled = const [],
    this.markValue = 1,
    super.success,
  });

  final int modulus;
  final TableMode mode;

  /// Índexs (fila·n + columna) de les caselles que ja venen escrites
  /// (només en mode [TableMode.fill]).
  final List<int> prefilled;

  /// Valor que cal marcar en mode [TableMode.markCells].
  final int markValue;

  int cell(int row, int col) => toProfNotation((row + 1) * (col + 1), modulus);

  List<int> get solution => [
    for (var r = 0; r < modulus; r++)
      for (var c = 0; c < modulus; c++) cell(r, c),
  ];

  /// Índexs de les caselles que valen [markValue].
  Set<int> get markedCells => {
    for (var i = 0; i < modulus * modulus; i++)
      if (solution[i] == markValue) i,
  };

  /// Elements de {1, …, n} que tenen invers.
  Set<int> get invertibles => {
    for (var x = 1; x <= modulus; x++)
      if (inverse(x, modulus) != null) x,
  };

  /// La resposta correcta en el format que espera [check].
  Object get expectedAnswer => switch (mode) {
    TableMode.fill => solution,
    TableMode.markCells => markedCells,
    TableMode.pickInvertible => invertibles,
  };

  @override
  bool check(Object answer) {
    switch (mode) {
      case TableMode.fill:
        if (answer is! List<int> || answer.length != modulus * modulus) {
          return false;
        }
        final s = solution;
        for (var i = 0; i < s.length; i++) {
          if (answer[i] != s[i]) return false;
        }
        return true;
      case TableMode.markCells:
      case TableMode.pickInvertible:
        final expected = expectedAnswer as Set<int>;
        return answer is Set<int> &&
            answer.length == expected.length &&
            answer.containsAll(expected);
    }
  }

  @override
  String get solutionLabel => switch (mode) {
    TableMode.fill => 'Taula de ℤ$modulus completa',
    TableMode.markCells => 'Productes que donen $markValue: ${_markedPairs()}',
    TableMode.pickInvertible => (invertibles.toList()..sort()).join(' i '),
  };

  String _markedPairs() => [
    for (final i in markedCells) '${i ~/ modulus + 1}·${i % modulus + 1}',
  ].join(', ');
}

enum TableMode {
  /// Omplir les caselles buides. Resposta: `List<int>` (n·n valors).
  fill,

  /// Marcar les caselles que valen `markValue`. Resposta: `Set<int>` d'índexs.
  markCells,

  /// Tocar els elements que tenen invers. Resposta: `Set<int>` d'elements.
  pickInvertible,
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
    super.celebration,
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
    super.celebration,
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
    this.wheelCount,
    this.locked = const [],
    this.offerNoSolution = false,
    super.success,
  }) : assert(solution != null || wheelCount != null);

  /// Resposta que envia el botó «No té solució».
  static const String noSolution = '∅';

  final List<String> symbols;

  /// Combinació correcta, o `null` si el pany no té solució.
  final List<String>? solution;

  /// Nombre de rodes quan no hi ha solució.
  final int? wheelCount;

  /// Posicions (0-based) de les rodes bloquejades.
  final List<int> locked;

  /// Mostra el botó «No té solució».
  final bool offerNoSolution;

  int get wheels => solution?.length ?? wheelCount!;

  @override
  bool check(Object answer) {
    final s = solution;
    if (s == null) return answer == noSolution;
    if (answer is! List<String> || answer.length != s.length) return false;
    for (var i = 0; i < s.length; i++) {
      if (answer[i] != s[i]) return false;
    }
    return true;
  }

  @override
  String get solutionLabel => solution?.join(' ') ?? 'No té solució';
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
    this.optional = false,
    this.bonus = 0,
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

  /// Un puzle opcional no cal per obrir la porta.
  final bool optional;

  /// Segons que es resten del temps total en resoldre'l.
  final int bonus;
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

  /// Xifra del pany «a d₁ c d₂ d₃» que dona la sala (1–7) i la seva posició
  /// (1–5). Varia per partida: surt de [Pany].
  final int digit;
  final int digitPosition;

  final List<Puzzle> puzzles;
}
