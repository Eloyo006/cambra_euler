import '../core/rng.dart';
import '../core/theme.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// Sala 1 · La Biblioteca: teoria de conjunts (apunts FOMA).
Room buildSala1(Variation v) => Room(
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
  digit: 3,
  digitPosition: 2,
  puzzles: [
    _registre(v.rng('1.1')),
    _reixa(v.rng('1.2')),
    _prestatgeria(v.rng('1.3')),
  ],
);

/// 1.1 · Venn.
Puzzle _registre(Rng r) => const Puzzle(
  id: '1.1',
  title: 'El registre de préstecs',
  source: 'Apunts FOMA · Conjunts',
  statement:
      "Sobre el faristol hi ha el registre de préstecs d'Euler, tancat "
      "amb una sivella de números. A la primera pàgina diu: «40 "
      "lectors de l'Acadèmia. 25 s'han endut llibres en llatí "
      "(conjunt A), 18 en grec (conjunt B) i 7 en totes dues "
      "llengües.» La sivella s'obre amb el nombre de lectors que "
      "s'han endut algun llibre.",
  steps: [
    VennStep(
      prompt: 'Toca cada regió del diagrama i escriu-hi quants lectors hi ha.',
      regions: [18, 7, 11, 4],
      labels: ['Només A', 'A ∩ B', 'Només B', 'Cap dels dos'],
    ),
    CodeStep(
      prompt:
          'Quants lectors s\'han endut llibres en llatí o en grec? '
          '|A ∪ B| = ?',
      solution: '36',
    ),
  ],
  outro:
      "La sivella fa clic. Entre les pàgines del registre hi ha una "
      "clau de ferro: la de la reixa del gabinet de lectura.",
  hints: [
    "Comença pel centre: els que fan tots dos. Després, «només A» és "
        "25 menys els del centre.",
    "Principi d'inclusió-exclusió: |A ∪ B| = |A| + |B| − |A ∩ B|.",
    "Només A = 25 − 7, només B = 18 − 7. |A ∪ B| = 25 + 18 − 7 i "
        "els que no fan cap són 40 − |A ∪ B|.",
  ],
);

/// 1.2 · De Morgan.
Puzzle _reixa(Rng r) => const Puzzle(
  id: '1.2',
  title: 'La reixa de De Morgan',
  source: 'Apunts FOMA · Conjunts',
  statement:
      "La clau entra a la reixa del gabinet de lectura, però no gira. "
      "Sobre el pany hi ha gravat: «Només passa qui no ha llegit ni "
      "llatí ni grec», és a dir, (A ∪ B)′. El mecanisme es programa "
      "amb fitxes, i les que hi ha a la safata parlen sobretot de "
      "complementaris: A′ i B′.",
  steps: [
    ExpressionStep(
      prompt:
          'Construeix una expressió equivalent a (A ∪ B)′ '
          'fent servir A′ i B′.',
      target: '(A∪B)′',
      solution: 'A′ ∩ B′',
      tokens: ['A′', 'B′', 'A', 'B', '∩', '∪', '(', ')'],
    ),
    ExpressionStep(
      prompt:
          'La reixa té un segon forrellat, que demana (A ∩ B)′. '
          'Construeix-ne una expressió equivalent.',
      target: '(A∩B)′',
      solution: 'A′ ∪ B′',
      tokens: ['A′', 'B′', 'A', 'B', '∩', '∪', '(', ')'],
    ),
  ],
  outro:
      "La reixa s'obre amb un grinyol. A dins, els sis volums de "
      "l'obra d'Euler han caigut per terra davant d'una prestatgeria "
      "de tres calaixos.",
  hints: [
    "Pensa en un element que no és a A ∪ B. Pot ser a A? I a B?",
    "Lleis de De Morgan: el complementari intercanvia ∪ i ∩, i "
        "complementa cada conjunt.",
    "(A ∪ B)′ = A′ ∩ B′  i  (A ∩ B)′ = A′ ∪ B′.",
  ],
);

/// 1.3 · Particions i classes mod n.
Puzzle _prestatgeria(Rng r) => const Puzzle(
  id: '1.3',
  title: 'La prestatgeria',
  source: 'Apunts FOMA · Particions i relacions d\'equivalència',
  statement:
      "Els volums, numerats de l'1 al 6, s'han de tornar a guardar als "
      "tres calaixos. A la fusta, Euler hi va escriure la condició: "
      "cap calaix no pot quedar buit, i cada volum ha d'anar en "
      "exactament un calaix. És a dir, ha de ser una partició.",
  steps: [
    ChoiceStep(
      prompt: 'Quina d\'aquestes és una partició de {1, …, 6}?',
      options: [
        '{1,3,5}, {2,4,5}, {6}',
        '{1,3,5}, {2,4}, {6}',
        '{1,3}, {2,4}, {6}',
        '{1,2,3}, {4,5,6}, ∅',
      ],
      correctIndex: 1,
    ),
    PartitionStep(
      prompt:
          'Ara fes-ne una tu: arrossega els sis volums als tres '
          'calaixos. De moment, qualsevol partició val.',
      items: [1, 2, 3, 4, 5, 6],
      boxes: 3,
    ),
    PartitionStep(
      prompt:
          'Els calaixos no s\'obren: Euler hi guardava els volums amb '
          'la relació a ~ b ⇔ a ≡ b (mod 3). Posa una classe '
          'd\'equivalència a cada calaix.',
      items: [1, 2, 3, 4, 5, 6],
      boxes: 3,
      target: [
        {3, 6},
        {1, 4},
        {2, 5},
      ],
      success: 'Les classes mod 3 formen una partició: {3,6}, {1,4}, {2,5}.',
    ),
    ChoiceStep(
      prompt: 'Amb aquesta relació, quina és la classe [2]?',
      options: ['{2}', '{2, 4, 6}', '{2, 5}', '{1, 2}'],
      correctIndex: 2,
    ),
  ],
  hints: [
    "Una partició no pot repetir elements, ni deixar-ne cap fora, ni "
        "tenir parts buides.",
    "La classe [a] conté tots els b tals que b − a és múltiple de 3. "
        "Mira el residu de dividir cada llibre per 3.",
    "La partició és {1,3,5}, {2,4}, {6}. Classes mod 3: residu 0 → {3,6}, "
        "residu 1 → {1,4}, residu 2 → {2,5}.",
  ],
  outro:
      "Les classes d'equivalència sempre formen una partició: aquí és on "
      "es troben els conjunts i l'aritmètica modular. Quan l'últim "
      "volum encaixa, el calaix del mig s'obre sol. Al fons hi ha una "
      "fitxa de fusta amb un 3 gravat.",
);
