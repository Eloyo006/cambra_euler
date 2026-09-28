import '../core/modular.dart';
import '../core/rng.dart';
import '../core/theme.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// Sala 2 · La Sala dels Rellotges: aritmètica modular (ex. 1–8).
///
/// A cada taula de variants, la primera fila és la del PDF del professor.
/// Les solucions no s'escriuen a mà: es calculen amb `core/modular.dart`.
Room buildSala2(Variation v, int digit) => Room(
  id: 'sala2',
  number: 2,
  name: 'La Sala dels Rellotges',
  topic: 'Aritmètica modular',
  color: AppColors.clocks,
  intro:
      "Desenes de rellotges, i cap no marca la mateixa hora. Euler deia que "
      "el temps és el millor exemple de residu: quan arriba a les 12, torna "
      "a començar. El rellotger de la casa hi va deixar la feina a mitges…",
  digit: digit,
  digitPosition: 4,
  puzzles: [
    _taula(v.rng('2.1')),
    _armari(v.rng('2.2')),
    _cartes(v.rng('2.3'), digit),
  ],
);

// ─────────────────────── 2.1 · Taula de ℤ₅ (ex. 1) ───────────────────────

/// Elements de ℤ₅ dels quals es pregunta l'invers.
const _invertir = [2, 3, 4];

/// a·x ≡ b (mod 6) sense solució: mcd(a, 6) no divideix b.
const _senseSolucio = [
  (a: 2, b: 1),
  (a: 3, b: 2),
  (a: 4, b: 1),
  (a: 2, b: 5),
  (a: 3, b: 1),
  (a: 4, b: 3),
];

Puzzle _taula(Rng r) {
  final k = r.pick(_invertir);
  final inv = inverse(k, 5)!;
  final e = r.pick(_senseSolucio);
  final perque = e.a.isEven ? 'és parell' : 'és múltiple de 3';
  return Puzzle(
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
      const TableStep(
        prompt:
            'Completa la taula de ℤ₅: toca una casella buida i tria el '
            'valor al teclat. Recorda que 5 ≡ 0.',
        modulus: 5,
        // Caselles que ja venen escrites al PDF (fila·5 + columna, des de 0):
        // fila 1: col 2 · fila 2: col 1, 3, 4, 5 · fila 3: col 4 ·
        // fila 4: col 1, 3, 4.
        prefilled: [1, 5, 7, 8, 9, 13, 15, 17, 18],
      ),
      const TableStep(
        prompt:
            'Ara marca totes les caselles on surt un 1. Cada una és una '
            'parella d\'inversos.',
        modulus: 5,
        mode: TableMode.markCells,
      ),
      CodeStep(prompt: 'Quin és l\'invers de $k a ℤ₅?', solution: '$inv'),
      const TableStep(
        prompt:
            'Aquesta és la taula de ℤ₆ = {1, …, 6}. Toca els elements '
            'que tenen invers.',
        modulus: 6,
        mode: TableMode.pickInvertible,
      ),
      WheelLockStep(
        prompt:
            'El cadenat del rellotge demana x amb ${e.a}x ≡ ${e.b} (mod 6). '
            'Gira la roda o, si creus que no n\'hi ha cap, prem «No té '
            'solució».',
        symbols: const ['1', '2', '3', '4', '5', '6'],
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
      "$k·$inv = ${k * inv} ≡ 1 (mod 5). A ℤ₆, només les files de l'1 i del "
          "5 tenen un 1. I ${e.a}x mòdul 6 sempre $perque: mai no pot ser "
          "≡ ${e.b} (mod 6).",
    ],
  );
}

// ───────────────────────── 2.2 · Panys (ex. 2 i 3) ─────────────────────────

/// Primer pany: codi «a b c d» amb a i c fixos, p·b ≡ c i q·a ≡ d (mod 5).
const _pany1 = [
  (a: 4, c: 1, p: 3, q: 2),
  (a: 2, c: 3, p: 2, q: 3),
  (a: 3, c: 2, p: 4, q: 3),
  (a: 1, c: 4, p: 3, q: 4),
  (a: 4, c: 2, p: 2, q: 2),
];

/// Segon pany: codi «prefix + X» en vocals, amb k·X ≡ m (mod 5).
const _pany2 = [
  (prefix: 'eoi', k: 3, m: 1),
  (prefix: 'aui', k: 2, m: 1),
  (prefix: 'oea', k: 4, m: 3),
  (prefix: 'iuo', k: 3, m: 4),
  (prefix: 'uai', k: 4, m: 2),
  (prefix: 'eia', k: 2, m: 2),
];

const _vocals = ['a', 'e', 'i', 'o', 'u'];

Puzzle _armari(Rng r) {
  final p1 = r.pick(_pany1);
  final b = mod(inverse(p1.p, 5)! * p1.c, 5);
  final d = mod(p1.q * p1.a, 5);
  final p2 = r.pick(_pany2);
  final x = mod(inverse(p2.k, 5)! * p2.m, 5);
  return Puzzle(
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
            'Primer pany: el codi abcd té la forma ${p1.a}x${p1.c}y, amb '
            '${p1.p}b ≡ c i ${p1.q}a ≡ d (mod 5), i b i d entre 0 i 4. '
            'Gira les rodes lliures.',
        symbols: const ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
        solution: ['${p1.a}', '$b', '${p1.c}', '$d'],
        locked: const [0, 2],
      ),
      WheelLockStep(
        prompt:
            'Segon pany: vocals a=0, e=1, i=2, o=3, u=4. El codi és '
            '${p2.prefix}X, amb ${p2.k}X ≡ ${p2.m} (mod 5). Quina vocal '
            'és X?',
        symbols: _vocals,
        solution: [...p2.prefix.split(''), _vocals[x]],
        locked: const [0, 1, 2],
        success:
            'X = ${_vocals[x]}, i és l\'única: ${p2.k} té un sol invers '
            'mòdul 5.',
      ),
    ],
    outro:
        "L'armari s'obre. Al calaix de baix hi ha tres cartes lligades "
        "amb una cinta, cadascuna escrita en un xifrat diferent.",
    hints: [
      "Substitueix el que ja saps: a = ${p1.a} i c = ${p1.c}.",
      p1.c == 1
          ? "${p1.p}b ≡ 1 vol dir que b és l'invers de ${p1.p} mòdul 5."
          : "${p1.p}b ≡ ${p1.c} vol dir que b = ${p1.p}⁻¹·${p1.c} "
                "(mod 5): busca primer l'invers de ${p1.p}.",
      "b = $b (${p1.p}·$b = ${p1.p * b} ≡ ${p1.c}) i d ≡ ${p1.q}·${p1.a} = "
          "${p1.q * p1.a} ≡ $d. Al segon pany, X = $x.",
    ],
  );
}

// ────────────────────────── 2.3 · Xifrats (ex. 5–8) ──────────────────────────

/// Primera carta: missatge en clar i desplaçament de César.
const _cesar = [
  (text: 'BON DIA', k: 3),
  (text: 'BONA NIT', k: 5),
  (text: 'SALUT', k: 7),
  (text: 'BON VIATGE', k: 4),
  (text: 'FINS AVIAT', k: 10),
];

/// Segona carta: un xifrat mòdul 6 que no és injectiu. L'opció correcta és
/// sempre la tercera (s'hi barregen en mostrar-les).
const _maldestre = [
  (
    a: 2,
    b: 1,
    msg: 'BDF',
    options: [
      'Sí: és ABC',
      'Sí: és ACE',
      'No es pot saber: cada lletra té 2 orígens',
      'No: 2x + 1 no dona mai lletres senars',
    ],
  ),
  (
    a: 3,
    b: 2,
    msg: 'CFC',
    options: [
      'Sí: és ABA',
      'Sí: és CFC, no canvia',
      'No es pot saber: cada lletra té 3 orígens',
      'No: 3 i 6 són primers entre si',
    ],
  ),
  (
    a: 4,
    b: 1,
    msg: 'BFD',
    options: [
      'Sí: és ABC',
      'Sí: és DEF',
      'No es pot saber: cada lletra té 2 orígens',
      'No: 4x + 1 no és una funció',
    ],
  ),
];

/// Última carta: la paraula (ha de fer pensar en la Biblioteca) i d'on és.
const _paraules = [
  (word: 'LIBRO', llengua: 'castellà', ciutat: 'Madrid'),
  (word: 'LIVRE', llengua: 'francès', ciutat: 'París'),
  (word: 'BUCH', llengua: 'alemany', ciutat: 'Berlín'),
  (word: 'BOOK', llengua: 'anglès', ciutat: 'Londres'),
  (word: 'LIBER', llengua: 'llatí', ciutat: 'Roma'),
];

/// Claus afins e(x) = a·x + b (mod 27); a no és múltiple de 3.
const _afins = [
  (a: 2, b: 3),
  (a: 5, b: 1),
  (a: 4, b: 7),
  (a: 7, b: 2),
  (a: 2, b: 10),
];

Puzzle _cartes(Rng r, int digit) {
  final c = r.pick(_cesar);
  final cesar = affineEncrypt(c.text, 1, c.k).replaceAll(' ', '_');
  final m = r.pick(_maldestre);
  final w = r.pick(_paraules);
  final key = r.pick(_afins);
  final inv = inverse(key.a, 27)!;
  final xifrat = affineEncrypt(w.word, key.a, key.b);
  // Pista 3: la primera lletra desxifrada pas a pas.
  final y0 = alphabet27.indexOf(xifrat[0]);
  final dy = mod(y0 - key.b, 27);
  final x0 = mod(inv * dy, 27);
  return Puzzle(
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
            'La primera carta només diu $cesar, xifrat amb César, '
            'e(x) = x + ${c.k} (mod 27). Gira el disc interior fins al '
            'desplaçament correcte, busca cada lletra xifrada al disc '
            'interior i llegeix la de fora. Què diu?',
        accepted: [c.text],
        aid: StepAid.caesarWheel,
      ),
      shuffledChoice(
        r,
        prompt:
            'La segona és d\'un corresponsal maldestre: xifra les lletres '
            'A–F (A=0, …, F=5) amb e(x) = ${m.a}x + ${m.b} (mod 6) i envia '
            '${m.msg}. Es pot desxifrar?',
        options: m.options,
        correct: 2,
      ),
      TextStep(
        prompt:
            'L\'última és la resposta que Euler no va arribar a enviar al '
            'seu corresponsal de ${w.ciutat}: $xifrat, xifrat amb l\'afí '
            'e(x) = ${key.a}x + ${key.b} (mod 27). L\'invers de ${key.a} '
            'mòdul 27 és $inv. Què diu?',
        accepted: [w.word],
        aid: StepAid.affineTable,
        aidMinHints: 2,
        affine: key,
      ),
    ],
    hints: [
      "Per desfer x + ${c.k}, resta ${c.k} a cada lletra. Per desfer "
          "${key.a}x + ${key.b}, primer resta ${key.b} i després multiplica "
          "per l'invers de ${key.a}.",
      "Si a no té invers mòdul n, e(x) = ax + b no és injectiva: dues "
          "lletres diferents van a parar a la mateixa. (S'ha desbloquejat "
          "la taula x → ${key.a}x + ${key.b} a l'últim missatge.)",
      "x = $inv·(y − ${key.b}) mod 27. ${xifrat[0]} = $y0 → $inv·$dy = "
          "${inv * dy} ≡ $x0 = ${alphabet27[x0]}.",
    ],
    outro:
        "${w.word}: «llibre», en ${w.llengua}, la llengua del seu "
        "corresponsal de ${w.ciutat}. Sota la carta hi ha una roda dentada "
        "amb un $digit gravat. I potser a la Biblioteca hi ha un llibre que "
        "abans no hi era…",
  );
}
