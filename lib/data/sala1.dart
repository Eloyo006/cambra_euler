import '../core/rng.dart';
import '../core/theme.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// Sala 1 · La Biblioteca: teoria de conjunts (apunts FOMA).
///
/// A cada taula de variants, la primera fila és la del PDF del professor.
Room buildSala1(Variation v, int digit) => Room(
  id: 'sala1',
  number: 1,
  name: 'La Biblioteca',
  topic: 'Teoria de conjunts',
  color: AppColors.library,
  intro:
      "Prestatges fins al sostre i olor de paper vell. Euler deixava llibres "
      "a mig Sant Petersburg i ho apuntava tot. Aquí guardava una xifra, "
      "tancada darrere de tres enigmes: el registre, la reixa i la "
      "prestatgeria.",
  digit: digit,
  digitPosition: 2,
  puzzles: [
    _registre(v.rng('1.1')),
    _reixa(v.rng('1.2')),
    _prestatgeria(v.rng('1.3'), digit),
  ],
);

// ───────────────────────────── 1.1 · Venn ─────────────────────────────

/// Cens de lectors: total, llatí (A), grec (B) i totes dues (A ∩ B).
/// Condicions: 0 < ab < min(a, b) i a + b − ab < total (ningú a cap regió
/// buida).
const _cens = [
  (total: 40, a: 25, b: 18, ab: 7),
  (total: 50, a: 30, b: 22, ab: 9),
  (total: 36, a: 20, b: 17, ab: 5),
  (total: 45, a: 28, b: 19, ab: 8),
  (total: 60, a: 33, b: 29, ab: 12),
];

Puzzle _registre(Rng r) {
  final c = r.pick(_cens);
  final union = c.a + c.b - c.ab;
  return Puzzle(
    id: '1.1',
    title: 'El registre de préstecs',
    source: 'Apunts FOMA · Conjunts',
    statement:
        "Sobre el faristol hi ha el registre de préstecs d'Euler, tancat "
        "amb una sivella de números. A la primera pàgina diu: «${c.total} "
        "lectors de l'Acadèmia. ${c.a} s'han endut llibres en llatí "
        "(conjunt A), ${c.b} en grec (conjunt B) i ${c.ab} en totes dues "
        "llengües.» La sivella s'obre amb el nombre de lectors que "
        "s'han endut algun llibre.",
    steps: [
      VennStep(
        prompt:
            'Toca cada regió del diagrama i escriu-hi quants lectors hi ha.',
        regions: [c.a - c.ab, c.ab, c.b - c.ab, c.total - union],
        labels: const ['Només A', 'A ∩ B', 'Només B', 'Cap dels dos'],
      ),
      CodeStep(
        prompt:
            'Quants lectors s\'han endut llibres en llatí o en grec? '
            '|A ∪ B| = ?',
        solution: '$union',
      ),
    ],
    outro:
        "La sivella fa clic. Entre les pàgines del registre hi ha una "
        "clau de ferro: la de la reixa del gabinet de lectura.",
    hints: [
      "Comença pel centre: els que fan tots dos. Després, «només A» és "
          "${c.a} menys els del centre.",
      "Principi d'inclusió-exclusió: |A ∪ B| = |A| + |B| − |A ∩ B|.",
      "Només A = ${c.a} − ${c.ab}, només B = ${c.b} − ${c.ab}. "
          "|A ∪ B| = ${c.a} + ${c.b} − ${c.ab} i els que no fan cap són "
          "${c.total} − |A ∪ B|.",
    ],
  );
}

// ─────────────────────────── 1.2 · De Morgan ───────────────────────────

/// Un forrellat de la reixa: la frase gravada, l'expressió que demana
/// (compacta, per validar; i amb espais, per mostrar) i una resposta.
typedef _Forrellat = ({
  String gravat,
  String target,
  String shown,
  String solution,
});

const _unio = (
  gravat: 'Només passa qui no ha llegit ni llatí ni grec',
  target: '(A∪B)′',
  shown: '(A ∪ B)′',
  solution: 'A′ ∩ B′',
);
const _interseccio = (
  gravat: 'No passa qui ha llegit totes dues llengües',
  target: '(A∩B)′',
  shown: '(A ∩ B)′',
  solution: 'A′ ∪ B′',
);

/// Parells de forrellats. Cada expressió descriu literalment la seva frase.
const List<List<_Forrellat>> _reixes = [
  [_unio, _interseccio],
  [_interseccio, _unio],
  [
    (
      gravat: 'No passa qui no ha llegit llatí, ni qui ha llegit grec',
      target: '(A′∪B)′',
      shown: '(A′ ∪ B)′',
      solution: 'A ∩ B′',
    ),
    (
      gravat: 'No passa qui ha llegit llatí sense haver llegit grec',
      target: '(A∩B′)′',
      shown: '(A ∩ B′)′',
      solution: 'A′ ∪ B',
    ),
  ],
  [
    (
      gravat: 'No passa qui ha llegit llatí, ni qui no ha llegit grec',
      target: '(A∪B′)′',
      shown: '(A ∪ B′)′',
      solution: 'A′ ∩ B',
    ),
    (
      gravat: 'No passa qui ha llegit grec sense haver llegit llatí',
      target: '(A′∩B)′',
      shown: '(A′ ∩ B)′',
      solution: 'A ∪ B′',
    ),
  ],
];

Puzzle _reixa(Rng r) {
  final [f1, f2] = r.pick(_reixes);
  const tokens = ['A′', 'B′', 'A', 'B', '∩', '∪', '(', ')'];
  return Puzzle(
    id: '1.2',
    title: 'La reixa de De Morgan',
    source: 'Apunts FOMA · Conjunts',
    statement:
        "La clau entra a la reixa del gabinet de lectura, però no gira. "
        "Sobre el pany hi ha gravat: «${f1.gravat}», és a dir, ${f1.shown}. "
        "El mecanisme es programa amb fitxes, i les que hi ha a la safata "
        "parlen sobretot de complementaris: A′ i B′.",
    steps: [
      ExpressionStep(
        prompt:
            'Construeix una expressió equivalent a ${f1.shown} sense '
            'complementar cap parèntesi.',
        target: f1.target,
        solution: f1.solution,
        tokens: tokens,
      ),
      ExpressionStep(
        prompt:
            'La reixa té un segon forrellat: «${f2.gravat}», és a dir, '
            '${f2.shown}. Construeix-ne una expressió equivalent.',
        target: f2.target,
        solution: f2.solution,
        tokens: tokens,
      ),
    ],
    outro:
        "La reixa s'obre amb un grinyol. A dins, els sis volums de "
        "l'obra d'Euler han caigut per terra davant d'una prestatgeria "
        "de tres calaixos.",
    hints: [
      "Pensa en un element de ${f1.shown}: què en pots dir, de si és a A? "
          "I de si és a B?",
      "Lleis de De Morgan: el complementari intercanvia ∪ i ∩, i "
          "complementa cada conjunt (i el complementari de A′ és A).",
      "${f1.shown} = ${f1.solution}  i  ${f2.shown} = ${f2.solution}.",
    ],
  );
}

// ──────────────────── 1.3 · Particions i classes mod 3 ────────────────────

/// Números dels sis volums.
const _volums = [
  [1, 2, 3, 4, 5, 6],
  [2, 3, 4, 5, 6, 7],
  [3, 4, 5, 6, 7, 8],
  [4, 5, 6, 7, 8, 9],
  [5, 6, 7, 8, 9, 10],
];

/// Formes de la partició correcta del test (posicions dins dels volums).
/// Cap no coincideix amb les classes mod 3, que és el pas següent.
const _formes = [
  [
    [0, 2, 4],
    [1, 3],
    [5],
  ],
  [
    [0, 1],
    [2, 3],
    [4, 5],
  ],
  [
    [0],
    [1, 2],
    [3, 4, 5],
  ],
  [
    [0, 1, 2],
    [3],
    [4, 5],
  ],
];

Puzzle _prestatgeria(Rng r, int digit) {
  final xs = r.pick(_volums);
  final forma = r.pick(_formes);
  final blocs = [
    for (final b in forma) [for (final i in b) xs[i]],
  ];
  String particio(List<List<int>> bs) =>
      bs.map((b) => b.isEmpty ? '∅' : setTight(b)).join(', ');

  // Opcions falses, amb les mateixes trampes que el PDF: un element repetit,
  // un que falta i una part buida.
  final gran = [
    for (var i = 0; i < 3; i++) i,
  ].reduce((m, i) => blocs[i].length > blocs[m].length ? i : m);
  final seguent = (gran + 1) % 3;
  final repetit = [
    for (var i = 0; i < 3; i++)
      i == seguent ? [...blocs[i], blocs[gran].last] : blocs[i],
  ];
  final falta = [
    for (var i = 0; i < 3; i++)
      i == gran ? blocs[i].sublist(0, blocs[i].length - 1) : blocs[i],
  ];
  final buida = [xs.sublist(0, 3), xs.sublist(3), <int>[]];

  // Classes mod 3, per residu 0, 1, 2.
  final classes = [
    for (var res = 0; res < 3; res++) {...xs.where((x) => x % 3 == res)},
  ];
  final classesText = classes.map(setTight).join(', ');

  // La classe [k] que es pregunta (al PDF, [2]).
  final k = r.pick([xs[1], xs[0], ...xs.sublist(2)]);
  final classeK = classes.firstWhere((c) => c.contains(k));
  final paritat = xs.where((x) => x.isEven == k.isEven);
  final veins = xs.contains(k - 1) ? [k - 1, k] : [k, k + 1];

  return Puzzle(
    id: '1.3',
    title: 'La prestatgeria',
    source: 'Apunts FOMA · Particions i relacions d\'equivalència',
    statement:
        "Els volums, numerats ${_rang(xs.first, xs.last)}, s'han de tornar a "
        "guardar als tres calaixos. A la fusta, Euler hi va escriure la "
        "condició: cap calaix no pot quedar buit, i cada volum ha d'anar en "
        "exactament un calaix. És a dir, ha de ser una partició.",
    steps: [
      shuffledChoice(
        r,
        prompt:
            'Quina d\'aquestes és una partició de '
            '{${xs.first}, …, ${xs.last}}?',
        options: [
          particio(repetit),
          particio(blocs),
          particio(falta),
          particio(buida),
        ],
        correct: 1,
      ),
      PartitionStep(
        prompt:
            'Ara fes-ne una tu: arrossega els sis volums als tres '
            'calaixos. De moment, qualsevol partició val.',
        items: xs,
        boxes: 3,
      ),
      PartitionStep(
        prompt:
            'Els calaixos no s\'obren: Euler hi guardava els volums amb '
            'la relació a ~ b ⇔ a ≡ b (mod 3). Posa una classe '
            'd\'equivalència a cada calaix.',
        items: xs,
        boxes: 3,
        target: classes,
        success: 'Les classes mod 3 formen una partició: $classesText.',
      ),
      shuffledChoice(
        r,
        prompt: 'Amb aquesta relació, quina és la classe [$k]?',
        options: [
          setSpaced([k]),
          setSpaced(paritat),
          setSpaced(classeK),
          setSpaced(veins),
        ],
        correct: 2,
      ),
    ],
    hints: [
      "Una partició no pot repetir elements, ni deixar-ne cap fora, ni "
          "tenir parts buides.",
      "La classe [a] conté tots els b tals que b − a és múltiple de 3. "
          "Mira el residu de dividir cada llibre per 3.",
      "La partició és ${particio(blocs)}. Classes mod 3: residu 0 → "
          "${setTight(classes[0])}, residu 1 → ${setTight(classes[1])}, "
          "residu 2 → ${setTight(classes[2])}.",
    ],
    outro:
        "Les classes d'equivalència sempre formen una partició: aquí és on "
        "es troben els conjunts i l'aritmètica modular. Quan l'últim "
        "volum encaixa, el calaix del mig s'obre sol. Al fons hi ha una "
        "fitxa de fusta amb un $digit gravat.",
  );
}

/// «de l'1 al 6», «del 2 al 7»… (apòstrof davant de vocal: 1 i 11).
String _rang(int from, int to) =>
    '${from == 1 || from == 11 ? "de l'" : 'del '}$from al $to';
