import '../core/rng.dart';
import '../core/theme.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// Sala 3 · La Torre del Dòmino: inducció (apunts FOMA).
///
/// A cada taula de variants, la primera fila és la del PDF del professor.
/// Les proves (3.1) i les proves falses (3.3) surten d'un banc; en totes
/// varien també l'ordre inicial i el de les opcions.
Room buildSala3(Variation v, int digit) => Room(
  id: 'sala3',
  number: 3,
  name: 'La Torre del Dòmino',
  topic: 'Inducció matemàtica',
  color: AppColors.domino,
  intro:
      "Una escala de cargol puja fins a l'observatori. Els néts d'Euler hi "
      "van posar fitxes de dòmino dretes a cada graó. «Si en cau una, "
      "cauen totes», els deia l'avi, «sempre que caigui la primera.» Cada "
      "replà és tancat amb una trapa.",
  digit: digit,
  digitPosition: 5,
  puzzles: [
    _prova(v.rng('3.1')),
    _hanoi(v.rng('3.2')),
    _falsa(v.rng('3.3'), digit),
    _divisibilitat(v.rng('3.4')),
  ],
);

// ─────────────────────── 3.1 · Prova per inducció ───────────────────────

/// Una pregunta de justificació sobre la prova.
typedef _Pregunta = ({String prompt, List<String> options, int correct});

/// Una prova per ordenar: sis línies en l'ordre correcte, dues preguntes de
/// justificació i les pistes.
typedef _Prova = ({
  String title,
  String enunciat,
  List<String> lines,
  _Pregunta q1,
  _Pregunta q2,
  List<String> hints,
});

const _pistaOrdre =
    "Una prova per inducció sempre comença pel cas base i acaba amb "
    "la conclusió. Entremig: hipòtesi → pas → càlcul.";

/// Proves de la sala. La primera (Bernoulli) és la dels apunts.
const List<_Prova> _proves = [
  (
    title: 'La prova de Bernoulli',
    enunciat: '(1 + a)ⁿ ≥ 1 + an per a tot n ≥ 0 i tot a ≥ −1',
    lines: [
      'Cas base (n = 0): (1+a)⁰ = 1 = 1 + a·0.',
      "Hipòtesi d'inducció: (1+a)ᵏ ≥ 1 + ak per a un cert k ≥ 0.",
      'Multipliquem per (1 + a) ≥ 0: (1+a)ᵏ⁺¹ ≥ (1 + ak)(1 + a).',
      'Desenvolupem: (1 + ak)(1 + a) = 1 + a(k+1) + a²k.',
      'Eliminem a²k ≥ 0: 1 + a(k+1) + a²k ≥ 1 + a(k+1).',
      'Conclusió: (1+a)ᵏ⁺¹ ≥ 1 + a(k+1). Per inducció, val per a tot n ≥ 0.',
    ],
    q1: (
      prompt:
          'Suposem (1+a)ᵏ ≥ 1 + ak. Per què podem multiplicar '
          'els dos costats per (1 + a) sense girar la desigualtat?',
      options: [
        'Perquè a > 0',
        'Perquè k ≥ 0',
        'Perquè a ≥ −1 ⇒ 1 + a ≥ 0',
        'Perquè (1+a)ᵏ > 0 sempre',
      ],
      correct: 2,
    ),
    q2: (
      prompt:
          '(1+a)ᵏ⁺¹ ≥ (1 + ak)(1 + a) = 1 + a(k+1) + a²k. '
          'Per què podem eliminar a²k?',
      options: [
        'Perquè a²k = 0',
        'Perquè a² ≥ 0 i k ≥ 0',
        'Perquè a ≥ −1',
        'Perquè a²k < 0',
      ],
      correct: 1,
    ),
    hints: [
      _pistaOrdre,
      "Multiplicar una desigualtat per un nombre negatiu la gira. "
          "Un quadrat mai no és negatiu.",
      "Ordre: cas base, hipòtesi, multiplicar, desenvolupar, eliminar a²k, "
          "conclusió. 1 + a ≥ 0 perquè a ≥ −1, i a²k ≥ 0.",
    ],
  ),
  (
    title: 'La suma dels senars',
    enunciat: '1 + 3 + 5 + … + (2n − 1) = n² per a tot n ≥ 1',
    lines: [
      'Cas base (n = 1): 1 = 1².',
      "Hipòtesi d'inducció: 1 + 3 + … + (2k − 1) = k² per a un cert k ≥ 1.",
      'El terme següent és 2(k + 1) − 1 = 2k + 1.',
      'Sumem-lo: 1 + 3 + … + (2k − 1) + (2k + 1) = k² + 2k + 1.',
      'Factoritzem: k² + 2k + 1 = (k + 1)².',
      'Conclusió: la suma dels k + 1 primers senars és (k + 1)². Per '
          'inducció, val per a tot n ≥ 1.',
    ],
    q1: (
      prompt: 'Per què el terme següent de la suma és 2k + 1?',
      options: [
        'Perquè el terme n-èsim és 2n − 1, i ara n = k + 1',
        'Perquè els senars comencen a 3',
        'Perquè 2k + 1 és parell',
        'Perquè ho diu el cas base',
      ],
      correct: 0,
    ),
    q2: (
      prompt: "On es fa servir la hipòtesi d'inducció?",
      options: [
        'Al cas base',
        'En substituir 1 + 3 + … + (2k − 1) per k²',
        'En factoritzar k² + 2k + 1',
        'Enlloc: no cal',
      ],
      correct: 1,
    ),
    hints: [
      _pistaOrdre,
      "El k-èsim senar és 2k − 1. I un quadrat perfecte: "
          "a² + 2a + 1 = (a + 1)².",
      "Ordre: cas base, hipòtesi, terme següent, sumar-lo, factoritzar, "
          "conclusió. La hipòtesi s'usa en substituir la suma per k².",
    ],
  ),
  (
    title: 'La suma de Gauss',
    enunciat: '1 + 2 + … + n = n(n + 1)/2 per a tot n ≥ 1',
    lines: [
      'Cas base (n = 1): 1 = 1·2/2.',
      "Hipòtesi d'inducció: 1 + 2 + … + k = k(k + 1)/2 per a un cert k ≥ 1.",
      'Sumem k + 1 als dos costats: 1 + 2 + … + k + (k + 1) = '
          'k(k + 1)/2 + (k + 1).',
      'Traiem factor comú (k + 1): k(k + 1)/2 + (k + 1) = (k + 1)(k/2 + 1).',
      'Operem: (k + 1)(k/2 + 1) = (k + 1)(k + 2)/2.',
      'Conclusió: 1 + … + (k + 1) = (k + 1)(k + 2)/2. Per inducció, val '
          'per a tot n ≥ 1.',
    ],
    q1: (
      prompt: 'Per què sumem k + 1 als dos costats?',
      options: [
        'Perquè és el terme següent de la suma',
        'Perquè k + 1 és parell',
        'Per simplificar la fracció',
        'Perquè ho demana el cas base',
      ],
      correct: 0,
    ),
    q2: (
      prompt: 'On ha d\'arribar el pas inductiu?',
      options: [
        'A k(k + 1)/2',
        'A (k + 1)(k + 2)/2',
        'A (k + 1)²/2',
        'A k(k + 2)/2',
      ],
      correct: 1,
    ),
    hints: [
      _pistaOrdre,
      "Per saber on has d'arribar, substitueix n per k + 1 a la fórmula "
          "n(n + 1)/2.",
      "Ordre: cas base, hipòtesi, sumar k + 1, factor comú, operar, "
          "conclusió. Cal arribar a (k + 1)(k + 2)/2.",
    ],
  ),
  (
    title: 'Els cubs i el 3',
    enunciat: 'n³ − n és múltiple de 3 per a tot n ≥ 0',
    lines: [
      'Cas base (n = 0): 0³ − 0 = 0, que és múltiple de 3.',
      "Hipòtesi d'inducció: k³ − k = 3q per a un cert k ≥ 0 i un enter q.",
      'Desenvolupem: (k + 1)³ − (k + 1) = k³ + 3k² + 3k + 1 − k − 1.',
      'Reagrupem: k³ + 3k² + 3k − k = (k³ − k) + 3k² + 3k.',
      'Substituïm la hipòtesi: (k³ − k) + 3k² + 3k = 3q + 3(k² + k) = '
          '3(q + k² + k).',
      'Conclusió: (k + 1)³ − (k + 1) és múltiple de 3. Per inducció, val '
          'per a tot n ≥ 0.',
    ],
    q1: (
      prompt: 'Per què agrupem k³ − k?',
      options: [
        'Perquè és el que la hipòtesi diu que és múltiple de 3',
        'Perquè k³ − k = 0',
        'Perquè k és múltiple de 3',
        'Per eliminar el cub',
      ],
      correct: 0,
    ),
    q2: (
      prompt: 'Per què 3k² + 3k és múltiple de 3?',
      options: [
        'Perquè k és múltiple de 3',
        'Perquè k² + k és parell',
        'Perquè és 3·(k² + k)',
        "Per la hipòtesi d'inducció",
      ],
      correct: 2,
    ),
    hints: [
      _pistaOrdre,
      "(k + 1)³ = k³ + 3k² + 3k + 1. Busca-hi el tros que coneixes per la "
          "hipòtesi.",
      "Ordre: cas base, hipòtesi, desenvolupar, reagrupar, substituir la "
          "hipòtesi, conclusió. 3k² + 3k = 3(k² + k).",
    ],
  ),
];

/// Ordres inicials de les sis línies (cap no és l'ordre correcte ni en
/// deixa més d'una al seu lloc).
const _ordres = [
  [3, 0, 5, 2, 4, 1],
  [2, 4, 0, 5, 1, 3],
  [5, 3, 1, 0, 2, 4],
  [1, 5, 4, 0, 3, 2],
  [4, 2, 3, 1, 5, 0],
];

Puzzle _prova(Rng r) {
  final p = r.pick(_proves);
  ChoiceStep pregunta(_Pregunta q) => shuffledChoice(
    r,
    prompt: q.prompt,
    options: q.options,
    correct: q.correct,
  );
  return Puzzle(
    id: '3.1',
    title: p.title,
    source: 'Apunts FOMA · Inducció',
    statement:
        "Al primer replà, sobre un faristol, hi ha la prova que Euler "
        "feia copiar als néts: per inducció, ${p.enunciat}. El corrent "
        "d'aire de l'escala n'ha barrejat els fulls, i la trapa no s'obrirà "
        "fins que la prova torni a estar en ordre.",
    steps: [
      OrderStep(
        prompt:
            'Arrossega les línies (per la maneta de la dreta) fins que '
            'la prova quedi en ordre.',
        lines: p.lines,
        initialOrder: r.pick(_ordres),
        success: 'Totes les fitxes cauen: la prova està en ordre!',
        celebration: Celebration.dominoes,
      ),
      pregunta(p.q1),
      pregunta(p.q2),
    ],
    outro:
        "Les fitxes cauen escala amunt, una rere l'altra, i l'última "
        "empeny la trapa del segon replà.",
    hints: p.hints,
  );
}

// ─────────────────────────── 3.2 · Torres de Hanoi ───────────────────────────

/// Nombre de discos de la pregunta «sense jugar» (el joc sempre és 3 i 4).
const _hanoiPregunta = [5, 6, 7, 8];

int _m(int n) => (1 << n) - 1;

Puzzle _hanoi(Rng r) {
  final k = r.pick(_hanoiPregunta);
  // «M(5) = 2·15 + 1 = 31», precedit dels valors intermedis si n'hi ha.
  final cadena = [
    for (var n = 3; n < k; n++) 'M($n) = ${_m(n)}',
    'M($k) = 2·${_m(k - 1)} + 1 = ${_m(k)}',
  ].join(', ');
  return Puzzle(
    id: '3.2',
    title: 'Les torres de Hanoi',
    source: 'Apunts FOMA · Inducció i progressions geomètriques',
    statement:
        "La trapa cap a l'observatori té un contrapès de discos de "
        "llautó enfilats en tres agulles. Només s'obre si els discos "
        "passen de l'agulla de l'esquerra a la de la dreta: d'un en un, "
        "sense posar mai un disc gran sobre un de petit, i sense ni un "
        "moviment de més. M(n) és el mínim de moviments amb n discos.",
    theory:
        "Per moure n discos: mou els n − 1 de dalt (M(n−1)), mou el gran "
        "(1) i torna a posar-hi els n − 1 (M(n−1)). "
        "Per tant, M(n) = 2·M(n−1) + 1, amb M(1) = 1.",
    steps: [
      const HanoiStep(
        prompt:
            'Toca una agulla per agafar el disc de dalt i una altra per '
            'deixar-lo. Primer, amb 3 discos i el mínim de moviments.',
        discs: 3,
        success: 'M(3) = 7.',
      ),
      const HanoiStep(
        prompt: 'Ara amb 4 discos, també amb el mínim de moviments.',
        discs: 4,
        success: 'M(4) = 15 = 2·7 + 1.',
      ),
      CodeStep(prompt: 'Sense jugar: quant val M($k)?', solution: '${_m(k)}'),
      shuffledChoice(
        r,
        prompt: 'Quina és la fórmula tancada de M(n)?',
        options: const [
          'M(n) = 2ⁿ',
          'M(n) = n²',
          'M(n) = 2ⁿ − 1',
          'M(n) = 2n − 1',
        ],
        correct: 2,
      ),
    ],
    outro:
        "El contrapès baixa i la trapa s'obre. Hanoi també és una suma "
        "geomètrica: 1 + 2 + 4 + … + 2ⁿ⁻¹ = 2ⁿ − 1.",
    hints: [
      "Amb 3 discos: porta els 2 petits a l'agulla del mig, mou el gran a "
          "la dreta i torna a posar-hi els 2 petits a sobre.",
      "Desplegant la recurrència surt 1 + 2 + 4 + … + 2ⁿ⁻¹: una suma "
          "geomètrica amb a₁ = 1 i r = 2.",
      "$cadena. Cada valor és una "
          "potència de 2 menys 1.",
    ],
  );
}

// ─────────────────────────── 3.3 · Prova falsa ───────────────────────────

/// Una prova per inducció que no s'aguanta: les línies, la que falla i una
/// pregunta per concretar per què.
typedef _Falsa = ({
  String title,
  String afirmacio,
  List<String> lines,
  int wrongLine,
  String tapSuccess,
  Celebration celebration,
  _Pregunta pregunta,
  String preguntaSuccess,
  List<String> hints,
});

/// Proves falses. Cadascuna falla d'una manera diferent: un pas que no val
/// per al k més petit, un cas base que no hi és i una desigualtat falsa.
/// La primera (els cavalls) és la dels apunts.
const List<_Falsa> _falses = [
  (
    title: 'Els cavalls del mateix color',
    afirmacio: 'tots els cavalls són del mateix color',
    lines: [
      'Afirmació: en tot grup de n ≥ 1 cavalls, tots són del mateix color.',
      "Cas base (n = 1): un grup d'un sol cavall té un sol color.",
      "Hipòtesi: tot grup de k cavalls és d'un sol color.",
      'Agafem k + 1 cavalls: c₁, c₂, …, cₖ₊₁.',
      'Els k primers, {c₁, …, cₖ}, són del mateix color (hipòtesi).',
      'Els k últims, {c₂, …, cₖ₊₁}, també ho són (hipòtesi).',
      'Els dos grups comparteixen cavalls, així que els k + 1 són '
          'del mateix color.',
      'Per inducció, tots els cavalls són del mateix color.',
    ],
    wrongLine: 6,
    tapSuccess:
        'Aquesta és la línia: els dos grups no sempre comparteixen cavalls.',
    celebration: Celebration.disjointHorses,
    pregunta: (
      prompt: 'Per a quin pas concret falla?',
      options: [
        'Al cas base n = 1',
        'Al pas de k = 1 a k + 1 = 2',
        'Al pas de k = 2 a k + 1 = 3',
        'La inducció no es pot fer servir amb cavalls',
      ],
      correct: 1,
    ),
    preguntaSuccess:
        "Amb k + 1 = 2, els grups són {c₁} i {c₂}: no comparteixen "
        "cap cavall, i la cadena es trenca.",
    hints: [
      "El cas base és cert. El problema és en algun pas concret.",
      "El pas inductiu ha de funcionar per a tot k ≥ 1, també per al més "
          "petit.",
      "Prova-ho amb k + 1 = 2: quins són els «k primers» i els «k últims»? "
          "Tenen algun cavall en comú?",
    ],
  ),
  (
    title: 'La fitxa que no cau',
    afirmacio: 'n = n + 1 per a tot n ≥ 0',
    lines: [
      'Afirmació: per a tot n ≥ 0, n = n + 1.',
      'Hipòtesi: k = k + 1 per a un cert k ≥ 0.',
      'Sumem 1 als dos costats: k + 1 = k + 2.',
      'Per tant, si val per a k, també val per a k + 1.',
      'Com que el pas inductiu funciona, per inducció val per a tot n ≥ 0.',
    ],
    wrongLine: 4,
    tapSuccess:
        'Aquesta és la línia: conclou sense haver comprovat cap cas base.',
    celebration: Celebration.none,
    pregunta: (
      prompt: 'Què li falta a la prova?',
      options: [
        'El cas base: amb n = 0 diria 0 = 1, que és fals',
        'Un pas inductiu correcte: sumar 1 no es pot fer',
        'Res: la prova és correcta',
        'Que k sigui parell',
      ],
      correct: 0,
    ),
    preguntaSuccess:
        "Sense cas base, la cadena no comença: si la primera fitxa no cau, "
        "no en cau cap.",
    hints: [
      "Mira les parts que ha de tenir tota prova per inducció. Hi són "
          "totes?",
      "El pas inductiu (de k a k + 1) és correcte. El problema és on "
          "comença la cadena.",
      "No hi ha cas base. Amb n = 0 l'afirmació diu 0 = 1: la primera "
          "fitxa no cau.",
    ],
  ),
  (
    title: 'Quadrats i potències',
    afirmacio: 'n² ≤ 2ⁿ per a tot n ≥ 1',
    lines: [
      'Afirmació: per a tot n ≥ 1, n² ≤ 2ⁿ.',
      'Cas base (n = 1): 1² = 1 ≤ 2 = 2¹.',
      'Hipòtesi: k² ≤ 2ᵏ per a un cert k ≥ 1.',
      '(k + 1)² = k² + 2k + 1 ≤ 2ᵏ + 2k + 1, per la hipòtesi.',
      'Com que 2k + 1 ≤ 2ᵏ, tenim 2ᵏ + 2k + 1 ≤ 2ᵏ + 2ᵏ = 2ᵏ⁺¹.',
      'Per inducció, n² ≤ 2ⁿ per a tot n ≥ 1.',
    ],
    wrongLine: 4,
    tapSuccess: 'Aquesta és la línia: 2k + 1 ≤ 2ᵏ no és cert per a tot k ≥ 1.',
    celebration: Celebration.none,
    pregunta: (
      prompt: 'Per a quins k falla «2k + 1 ≤ 2ᵏ»?',
      options: [
        'Només per a k = 5',
        'Per a cap k',
        'Per a k = 1 i k = 2',
        'Per a tots els k',
      ],
      correct: 2,
    ),
    preguntaSuccess:
        "Amb k = 1: 3 > 2, i amb k = 2: 5 > 4. De fet, n = 3 desmenteix "
        "l'afirmació: 3² = 9 > 8 = 2³.",
    hints: [
      "El cas base i la hipòtesi són correctes. Revisa cada desigualtat "
          "del pas inductiu.",
      "Una desigualtat que es fa servir al pas inductiu ha de ser certa per "
          "a tot k ≥ 1, també per als més petits.",
      "Prova 2k + 1 ≤ 2ᵏ amb k = 1 i k = 2. I prova l'afirmació amb n = 3.",
    ],
  ),
];

Puzzle _falsa(Rng r, int digit) {
  final f = r.pick(_falses);
  return Puzzle(
    id: '3.3',
    title: f.title,
    source: 'Apunts FOMA · Inducció (prova falsa)',
    statement:
        "A l'observatori, al costat del telescopi, hi ha el quadern d'un "
        "deixeble massa confiat que «demostra» per inducció que "
        "${f.afirmacio}. Al marge, amb la lletra d'Euler: «Troba on falla i "
        "tindràs l'última xifra.»",
    steps: [
      TapLineStep(
        prompt: 'Toca la línia on falla la prova.',
        lines: f.lines,
        wrongLine: f.wrongLine,
        success: f.tapSuccess,
        celebration: f.celebration,
      ),
      shuffledChoice(
        r,
        prompt: f.pregunta.prompt,
        options: f.pregunta.options,
        correct: f.pregunta.correct,
        success: f.preguntaSuccess,
      ),
    ],
    outro:
        "Quan passes el full, dins de la tapa del quadern hi ha un $digit "
        "escrit en tinta vermella. Per la finestra de l'observatori, el "
        "cel ja comença a clarejar.",
    hints: f.hints,
  );
}

// ───────────────────── 3.4 · Divisibilitat (ex. 11 i 30) ─────────────────────

/// Ex. 11: bases b ≡ 1 (mod 4), així bⁿ + 1 ≡ 2 (mod 4).
const _ex11 = [5, 9, 13, 17];

/// Ex. 30: bᵉ ≡ 1 (mod 10), així bᵉⁿ + 9 ≡ 0 (mod 10). [pow] = bᵉ.
const _ex30 = [
  (b: 3, e: 4, pow: 81),
  (b: 7, e: 4, pow: 2401),
  (b: 9, e: 2, pow: 81),
  (b: 13, e: 4, pow: 28561),
];

const _supDigits = '⁰¹²³⁴⁵⁶⁷⁸⁹';
String _sup(int n) =>
    '$n'.split('').map((d) => _supDigits[int.parse(d)]).join();

Puzzle _divisibilitat(Rng r) {
  final b11 = r.pick(_ex11);
  final x = r.pick(_ex30);
  final e = _sup(x.e);
  return Puzzle(
    id: '3.4',
    title: 'Divisibilitat (bonus)',
    source: "Llista d'exercicis · Ex. 11 i 30",
    optional: true,
    bonus: 60,
    statement:
        "Enganxada al telescopi hi ha una última nota d'Euler: «Per a qui "
        "encara tingui temps.» És un enigma opcional: no cal per obrir la "
        "porta, però si el resols et resta 60 s de la nit. Demostra-ho "
        "per inducció fent servir congruències.\n"
        "Ex. 11: $b11ⁿ + 1 és divisible per 2 però no per 4.\n"
        "Ex. 30: ${x.b}$eⁿ + 9 és múltiple de 10.",
    steps: [
      CodeStep(prompt: 'Ex. 11 · Quant val $b11 mòdul 4?', solution: '1'),
      CodeStep(
        prompt:
            'Si $b11ᵏ ≡ 1 (mod 4), llavors $b11ᵏ⁺¹ = $b11·$b11ᵏ ≡ 1. Per tant, '
            'quant val $b11ⁿ + 1 mòdul 4?',
        solution: '2',
        success: '$b11ⁿ + 1 ≡ 2 (mod 4): és parell, però no és múltiple de 4.',
      ),
      CodeStep(
        prompt: 'Ex. 30 · Quant val ${x.b}$e = ${x.pow} mòdul 10?',
        solution: '1',
      ),
      shuffledChoice(
        r,
        prompt:
            'Pas inductiu: si ${x.b}$eᵏ + 9 ≡ 0 (mod 10), per què també '
            '${x.b}$e⁽ᵏ⁺¹⁾ + 9 ≡ 0 (mod 10)?',
        options: [
          'Perquè ${x.b}$e⁽ᵏ⁺¹⁾ = ${x.pow}·${x.b}$eᵏ ≡ 1·${x.b}$eᵏ (mod 10)',
          'Perquè ${x.b} i 10 no tenen divisors comuns',
          'Perquè ${x.pow} és un quadrat perfecte',
          'Perquè 9 és senar',
        ],
        correct: 0,
        success: '${x.b}$eⁿ + 9 ≡ 1 + 9 ≡ 0 (mod 10). Bonus aconseguit: −60 s!',
      ),
    ],
    hints: [
      "Treballa amb residus: només importa el residu de $b11 (o de "
          "${x.pow}) en dividir.",
      "Si a ≡ 1 (mod m), aleshores aᵏ ≡ 1ᵏ = 1 (mod m): es demostra per "
          "inducció multiplicant per a a cada pas.",
      "$b11 ≡ 1 (mod 4), així que $b11ⁿ + 1 ≡ 2. I ${x.pow} ≡ 1 (mod 10), "
          "així que ${x.b}$eⁿ + 9 ≡ 1 + 9 ≡ 0.",
    ],
  );
}
