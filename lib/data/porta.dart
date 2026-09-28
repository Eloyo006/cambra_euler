import '../core/rng.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// La porta d'Euler (Ex. 4). El pany «a 3 c 5 4» viu a ℤ₇ = {1, …, 7}.
Puzzle buildPorta(Variation v) => _porta(v.rng('porta'));

Puzzle _porta(Rng r) => const Puzzle(
  id: 'porta',
  title: "La porta d'Euler",
  source: 'Llista d\'exercicis · Ex. 4',
  statement:
      "Tornes al vestíbul amb les tres xifres. Les rodes del pany «a 3 c 5 4» "
      "tenen set posicions, com els dies de la setmana: funcionen a "
      "ℤ₇ = {1, …, 7}. Falten a i c, i les condicions que han de complir no "
      "són a la porta: Euler les va amagar en un llibre. Afanya't: al carrer "
      "ja se sent la carrossa de l'Acadèmia.",
  steps: [
    CodeStep(
      prompt: 'Primer, a: quin element de ℤ₇ multiplicat per 3 dona 1?',
      solution: '5',
    ),
    CodeStep(prompt: 'Ara c: quin c de ℤ₇ compleix 5c ≡ 4?', solution: '5'),
    WheelLockStep(
      prompt:
          'Gira les rodes lliures fins a «a 3 c 5 4». Les xifres de les sales '
          'ja hi són.',
      symbols: ['1', '2', '3', '4', '5', '6', '7'],
      solution: ['5', '3', '5', '5', '4'],
      locked: [1, 3, 4],
    ),
  ],
  hints: [
    "a és el nombre que multiplicat per 3 dona 1 mòdul 7.",
    "Prova els valors de l'1 al 7. Per a c, calcula 5c mod 7 fins que doni 4.",
    "3·5 = 15 ≡ 1 i 5·5 = 25 ≡ 4 (mod 7). El codi és a 3 c 5 4.",
  ],
);

/// Text del quadern amagat: les condicions de la porta.
String buildSecretBookText(Variation v) =>
    "Al calaix del mig de la prestatgeria, darrere dels sis volums, hi ha un "
    "quadern petit que brilla a la llum de l'espelma. És el quadern de "
    "butxaca d'Euler. A l'última pàgina, amb la lletra que li quedava quan "
    "ja no hi veia:\n\n«a és l'invers de 3; c·5 ≡ 4, a ℤ₇.»";
