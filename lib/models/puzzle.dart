import 'package:flutter/painting.dart';

enum StepKind { code, text, choice }

/// Un pas d'un puzle. La validació és pura: [check] no depèn de cap widget.
class PuzzleStep {
  const PuzzleStep.code({
    required this.prompt,
    required String this.solution,
    this.success,
  })  : kind = StepKind.code,
        accepted = const [],
        options = const [],
        correctIndex = -1;

  const PuzzleStep.text({
    required this.prompt,
    required this.accepted,
    this.success,
  })  : kind = StepKind.text,
        solution = null,
        options = const [],
        correctIndex = -1;

  const PuzzleStep.choice({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.success,
  })  : kind = StepKind.choice,
        solution = null,
        accepted = const [];

  final StepKind kind;
  final String prompt;

  /// Codi correcte (code).
  final String? solution;

  /// Respostes acceptades (text). La primera és la «oficial».
  final List<String> accepted;

  /// Opcions (choice).
  final List<String> options;
  final int correctIndex;

  /// Missatge que es mostra quan el pas s'encerta.
  final String? success;

  /// La resposta correcta, per mostrar-la un cop resolt el pas.
  String get solutionLabel => switch (kind) {
        StepKind.code => solution!,
        StepKind.text => accepted.first,
        StepKind.choice => options[correctIndex],
      };

  bool check(Object answer) {
    switch (kind) {
      case StepKind.code:
        return answer is String &&
            normalizeCode(answer) == normalizeCode(solution!);
      case StepKind.text:
        return answer is String &&
            accepted.any((a) => normalizeText(a) == normalizeText(answer));
      case StepKind.choice:
        return answer is int && answer == correctIndex;
    }
  }

  /// Treu espais i guions: «4 2 1 3» → «4213».
  static String normalizeCode(String s) =>
      s.replaceAll(RegExp(r'[\s\-_]'), '').toUpperCase();

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
