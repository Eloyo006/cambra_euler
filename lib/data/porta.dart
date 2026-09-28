import '../core/modular.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// El pany «a d₁ c d₂ d₃» de la partida, a ℤ₇ = {1, …, 7} (notació del PDF).
///
/// Les xifres d₁, d₂, d₃ les donen les sales 1, 2 i 3; a i c es calculen a
/// la porta: a = k⁻¹ i m·c ≡ t (mod 7). Tot el que en parla (sales, porta,
/// quadern, intro) ho llegeix d'aquí, perquè no es puguin contradir.
class Pany {
  const Pany({
    required this.digits,
    required this.k,
    required this.m,
    required this.t,
  });

  /// Xifres de les sales 1, 2 i 3 (posicions 2, 4 i 5 del pany).
  final (int, int, int) digits;

  /// a és l'invers de [k]; c compleix [m]·c ≡ [t] (mod 7).
  final int k, m, t;

  int get a => toProfNotation(inverse(k, 7)!, 7);
  int get c => toProfNotation(inverse(m, 7)! * t, 7);

  /// «a 3 c 5 4».
  String get pattern => 'a ${digits.$1} c ${digits.$2} ${digits.$3}';

  /// La combinació completa, roda per roda.
  List<String> get code => [
    '$a',
    '${digits.$1}',
    '$c',
    '${digits.$2}',
    '${digits.$3}',
  ];
}

/// Xifres de les sales (d₁, d₂, d₃), de 1 a 7.
const _xifres = [
  (3, 5, 4),
  (2, 6, 1),
  (4, 1, 6),
  (6, 3, 2),
  (1, 4, 7),
  (5, 2, 3),
  (7, 5, 1),
];

/// Condicions de la porta: a = k⁻¹ i m·c ≡ t (mod 7), amb t ≠ 0.
const _condicions = [
  (k: 3, m: 5, t: 4),
  (k: 2, m: 3, t: 6),
  (k: 4, m: 2, t: 5),
  (k: 5, m: 4, t: 3),
  (k: 6, m: 3, t: 1),
  (k: 3, m: 6, t: 2),
];

Pany buildPany(Variation v) {
  final r = v.rng('pany');
  final cond = r.pick(_condicions);
  return Pany(digits: r.pick(_xifres), k: cond.k, m: cond.m, t: cond.t);
}

/// La porta d'Euler (Ex. 4).
Puzzle buildPorta(Pany p) => Puzzle(
  id: 'porta',
  title: "La porta d'Euler",
  source: 'Llista d\'exercicis · Ex. 4',
  statement:
      "Tornes al vestíbul amb les tres xifres. Les rodes del pany "
      "«${p.pattern}» tenen set posicions, com els dies de la setmana: "
      "funcionen a ℤ₇ = {1, …, 7}. Falten a i c, i les condicions que han "
      "de complir no són a la porta: Euler les va amagar en un llibre. "
      "Afanya't: al carrer ja se sent la carrossa de l'Acadèmia.",
  steps: [
    CodeStep(
      prompt: 'Primer, a: quin element de ℤ₇ multiplicat per ${p.k} dona 1?',
      solution: '${p.a}',
    ),
    CodeStep(
      prompt: 'Ara c: quin c de ℤ₇ compleix ${p.m}c ≡ ${p.t}?',
      solution: '${p.c}',
    ),
    WheelLockStep(
      prompt:
          'Gira les rodes lliures fins a «${p.pattern}». Les xifres de les '
          'sales ja hi són.',
      symbols: const ['1', '2', '3', '4', '5', '6', '7'],
      solution: p.code,
      locked: const [1, 3, 4],
    ),
  ],
  hints: [
    "a és el nombre que multiplicat per ${p.k} dona 1 mòdul 7.",
    "Prova els valors de l'1 al 7. Per a c, calcula ${p.m}c mod 7 fins que "
        "doni ${p.t}.",
    "${p.k}·${p.a} = ${p.k * p.a} ≡ 1 i ${p.m}·${p.c} = ${p.m * p.c} ≡ ${p.t} "
        "(mod 7). El codi és ${p.pattern}.",
  ],
);

/// Text del quadern amagat: les condicions de la porta.
String buildSecretBookText(Pany p) =>
    "Al calaix del mig de la prestatgeria, darrere dels sis volums, hi ha un "
    "quadern petit que brilla a la llum de l'espelma. És el quadern de "
    "butxaca d'Euler. A l'última pàgina, amb la lletra que li quedava quan "
    "ja no hi veia:\n\n«a és l'invers de ${p.k}; c·${p.m} ≡ ${p.t}, a ℤ₇.»";
