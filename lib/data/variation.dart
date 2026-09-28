import '../core/rng.dart';
import '../models/puzzle.dart';

/// Llavor especial: la partida amb les dades del PDF del professor (la
/// primera fila de cada taula de variants, sense barrejar res). La fan servir
/// els tests de la §4, les captures i les partides desades abans de les
/// variants. Les llavors de les partides noves són sempre ≥ 0.
const int pdfSeed = -1;

/// La variació d'una partida: dona a cada puzle el seu generador.
class Variation {
  const Variation(this.seed);

  final int seed;

  /// Generador propi de [key] (un id de puzle, 'porta'…).
  Rng rng(String key) => seed == pdfSeed ? Rng.first() : Rng(seed, key);
}

/// Un [ChoiceStep] amb les opcions barrejades. [options] va en l'ordre
/// «oficial» (el del PDF) i [correct] n'és l'índex correcte.
ChoiceStep shuffledChoice(
  Rng r, {
  required String prompt,
  required List<String> options,
  required int correct,
  String? success,
}) {
  final order = r.shuffled([for (var i = 0; i < options.length; i++) i]);
  return ChoiceStep(
    prompt: prompt,
    options: [for (final i in order) options[i]],
    correctIndex: order.indexOf(correct),
    success: success,
  );
}

/// «{1,3,5}» (sense espais), com als enunciats de particions.
String setTight(Iterable<int> xs) => '{${(xs.toList()..sort()).join(',')}}';

/// «{2, 5}» (amb espais), com a les opcions de classes.
String setSpaced(Iterable<int> xs) => '{${(xs.toList()..sort()).join(', ')}}';
