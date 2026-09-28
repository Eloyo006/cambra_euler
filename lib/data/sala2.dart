import '../core/rng.dart';
import '../core/theme.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// Sala 2 · La Sala dels Rellotges: aritmètica modular (ex. 1–8).
Room buildSala2(Variation v) => Room(
  id: 'sala2',
  number: 2,
  name: 'La Sala dels Rellotges',
  topic: 'Aritmètica modular',
  color: AppColors.clocks,
  intro:
      "Desenes de rellotges, i cap no marca la mateixa hora. Euler deia que "
      "el temps és el millor exemple de residu: quan arriba a les 12, torna "
      "a començar. El rellotger de la casa hi va deixar la feina a mitges…",
  digit: 5,
  digitPosition: 4,
  puzzles: [_taula(v.rng('2.1')), _armari(v.rng('2.2')), _cartes(v.rng('2.3'))],
);

/// 2.1 · Taula de ℤ₅ i inversos (ex. 1).
Puzzle _taula(Rng r) => const Puzzle(
  id: '2.1',
  title: 'La taula del rellotger',
  source: 'Llista d\'exercicis · Ex. 1',
  statement:
      "El gran rellotge de peu està aturat, i el seu mecanisme té un "
      "cadenat. Sobre el taulell, el rellotger va deixar les taules "
      "d'engranatges: la de multiplicar de ℤ₅ = {1, …, 5}, amb "
      "5 ≡ 0, a mig omplir, i la de ℤ₆. Per tornar-lo a posar en "
      "marxa cal saber quines rodes tenen parella: quins elements "
      "tenen invers.",
  theory:
      "Un element x té invers a ℤₙ si existeix y amb x·y ≡ 1 (mod n). "
      "A la taula, busca on surt un 1.",
  steps: [
    TableStep(
      prompt:
          'Completa la taula de ℤ₅: toca una casella buida i tria el '
          'valor al teclat. Recorda que 5 ≡ 0.',
      modulus: 5,
      // Caselles que ja venen escrites al PDF (fila·5 + columna, des de 0):
      // fila 1: col 2 · fila 2: col 1, 3, 4, 5 · fila 3: col 4 ·
      // fila 4: col 1, 3, 4.
      prefilled: [1, 5, 7, 8, 9, 13, 15, 17, 18],
    ),
    TableStep(
      prompt:
          'Ara marca totes les caselles on surt un 1. Cada una és una '
          'parella d\'inversos.',
      modulus: 5,
      mode: TableMode.markCells,
    ),
    CodeStep(prompt: 'Quin és l\'invers de 2 a ℤ₅?', solution: '3'),
    TableStep(
      prompt:
          'Aquesta és la taula de ℤ₆ = {1, …, 6}. Toca els elements '
          'que tenen invers.',
      modulus: 6,
      mode: TableMode.pickInvertible,
    ),
    WheelLockStep(
      prompt:
          'El cadenat del rellotge demana x amb 2x ≡ 1 (mod 6). Gira '
          'la roda o, si creus que no n\'hi ha cap, prem «No té '
          'solució».',
      symbols: ['1', '2', '3', '4', '5', '6'],
      solution: null,
      wheelCount: 1,
      offerNoSolution: true,
    ),
  ],
  outro:
      "No hi havia cap x: el cadenat era un parany. El rellotge es posa "
      "en marxa i toca les hores. A la paret, la porta de l'armari del "
      "rellotger queda entreoberta, però la tanquen dos cadenats més.",
  hints: [
    "Multiplica cada fila per cada columna i queda't amb el residu en "
        "dividir per 5 (si dona 0, escriu 5).",
    "x té invers a ℤₙ si a la seva fila de la taula hi surt un 1. "
        "Això passa quan mcd(x, n) = 1.",
    "2·3 = 6 ≡ 1 (mod 5). A ℤ₆, només les files de l'1 i del 5 tenen "
        "un 1. I 2x sempre és parell: mai no pot ser ≡ 1 (mod 6).",
  ],
);

/// 2.2 · Panys (ex. 2 i 3).
Puzzle _armari(Rng r) => const Puzzle(
  id: '2.2',
  title: 'L\'armari del rellotger',
  source: 'Llista d\'exercicis · Ex. 2 i 3',
  statement:
      "L'armari on el rellotger guardava la correspondència d'Euler "
      "té dos cadenats. A la porta hi ha enganxada una nota: «Totes "
      "les condicions són mòdul 5, com les cinc rodes del meu primer "
      "rellotge.»",
  steps: [
    WheelLockStep(
      prompt:
          'Primer pany: el codi abcd té la forma 4x1y, amb '
          '3b ≡ c i 2a ≡ d (mod 5). Gira les rodes lliures.',
      symbols: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      solution: ['4', '2', '1', '3'],
      locked: [0, 2],
    ),
    WheelLockStep(
      prompt:
          'Segon pany: vocals a=0, e=1, i=2, o=3, u=4. El codi és '
          'eoiX, amb 3X ≡ 1 (mod 5). Quina vocal és X?',
      symbols: ['a', 'e', 'i', 'o', 'u'],
      solution: ['e', 'o', 'i', 'i'],
      locked: [0, 1, 2],
      success: 'X = i, i és l\'única: 3 té un sol invers mòdul 5.',
    ),
  ],
  outro:
      "L'armari s'obre. Al calaix de baix hi ha tres cartes lligades "
      "amb una cinta, cadascuna escrita en un xifrat diferent.",
  hints: [
    "Substitueix el que ja saps: a = 4 i c = 1.",
    "3b ≡ 1 vol dir que b és l'invers de 3 mòdul 5.",
    "b = 2 (3·2 = 6 ≡ 1) i d ≡ 2·4 = 8 ≡ 3. Al segon pany, X = 2.",
  ],
);

/// 2.3 · Xifrats (ex. 5–8).
Puzzle _cartes(Rng r) => const Puzzle(
  id: '2.3',
  title: 'Les cartes xifrades',
  source: 'Llista d\'exercicis · Ex. 5, 6, 7 i 8',
  statement:
      "Euler s'escrivia amb matemàtics de mitja Europa, i als més "
      "curiosos els contestava en xifrat. Per llegir les tres cartes, "
      "fes servir l'alfabet de 27 lletres: A=0, B=1, …, N=13, Ç=14, "
      "O=15, …, Z=26.",
  theory:
      "Ex. 5 · g(x) = 2x a ℤ₇: g(3) = 6, g(5) = 3, g⁻¹(4) = 2 i "
      "g⁻¹(2) = 1. És bijectiva, però és un xifrat dolent: n'hi ha prou "
      "amb un parell (x, g(x)) per trencar-lo.",
  steps: [
    TextStep(
      prompt:
          'La primera carta només diu ERP_GLD, xifrat amb César, '
          'e(x) = x + 3 (mod 27). Gira el disc interior fins al '
          'desplaçament correcte, busca cada lletra xifrada al disc '
          'interior i llegeix la de fora. Què diu?',
      accepted: ['BON DIA'],
      aid: StepAid.caesarWheel,
    ),
    ChoiceStep(
      prompt:
          'La segona és d\'un corresponsal maldestre: xifra les lletres '
          'A–F (A=0, …, F=5) amb e(x) = 2x + 1 (mod 6) i envia BDF. '
          'Es pot desxifrar?',
      options: [
        'Sí: és ABC',
        'Sí: és ACE',
        'No es pot saber: cada lletra té 2 orígens',
        'No: 2x + 1 no dona mai lletres senars',
      ],
      correctIndex: 2,
    ),
    TextStep(
      prompt:
          'L\'última és la resposta que Euler no va arribar a enviar al '
          'seu corresponsal de Madrid: YSFMG, xifrat amb l\'afí '
          'e(x) = 2x + 3 (mod 27). L\'invers de 2 mòdul 27 és 14. '
          'Què diu?',
      accepted: ['LIBRO'],
      aid: StepAid.affineTable,
      aidMinHints: 2,
    ),
  ],
  hints: [
    "Per desfer x + 3, resta 3 a cada lletra. Per desfer 2x + 3, primer "
        "resta 3 i després multiplica per l'invers de 2.",
    "Si a no té invers mòdul n, e(x) = ax + b no és injectiva: dues "
        "lletres diferents van a parar a la mateixa. (S'ha desbloquejat "
        "la taula x → 2x + 3 a l'últim missatge.)",
    "x = 14·(y − 3) mod 27. Y = 25 → 14·22 = 308 ≡ 11 = L.",
  ],
  outro:
      "LIBRO: «llibre», en la llengua del seu corresponsal de Madrid. "
      "Sota la carta hi ha una roda dentada amb un 5 gravat. I potser "
      "a la Biblioteca hi ha un llibre que abans no hi era…",
);
