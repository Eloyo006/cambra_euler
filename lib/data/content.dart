import '../core/theme.dart';
import '../models/puzzle.dart';

/// Tot el contingut del joc. Els enunciats són fixos (no aleatoris).
/// Les solucions es verifiquen a `test/content_test.dart`.

const List<int> hintPenalties = [30, 60, 120];
const List<String> hintLabels = ['Suggeriment', 'Teoria', 'Gairebé la solució'];

const String introText =
    "Leonhard Euler va deixar tancada la seva cambra de treball amb un pany "
    "de cinc xifres. Sobre la porta només es llegeix: «a 3 c 5 4».\n\n"
    "Cada una de les tres sales del vestíbul guarda una xifra del pany. "
    "Resol els enigmes de conjunts, d'aritmètica modular i d'inducció, "
    "i després calcula a i c per obrir la porta.\n\n"
    "El rellotge corre. Cada pista que demanis afegeix temps.";

const String victoryText =
    "«Llegiu Euler, llegiu Euler: és el mestre de tots nosaltres.»\n"
    "Has obert la cambra. Euler estaria orgullós: conjunts, congruències i "
    "inducció, tot en una sola tarda.";

const List<Room> rooms = [
  // ───────────────────────────── Sala 1 ─────────────────────────────
  Room(
    id: 'sala1',
    number: 1,
    name: 'La Biblioteca',
    topic: 'Teoria de conjunts',
    color: AppColors.library,
    intro:
        "Prestatges fins al sostre i un fitxer ple de diagrames de Venn. "
        "Algú ha classificat els lectors en conjunts…",
    digit: 3,
    digitPosition: 2,
    puzzles: [
      Puzzle(
        id: '1.1',
        title: 'El cens de lectors',
        source: 'Apunts FOMA · Conjunts',
        statement:
            "La Biblioteca té 40 alumnes inscrits. 25 programen en "
            "Flutter (conjunt A), 18 en Angular (conjunt B) i 7 en tots dos.",
        steps: [
          VennStep(
            prompt:
                'Toca cada regió del diagrama i escriu-hi quants alumnes hi ha.',
            regions: [18, 7, 11, 4],
            labels: ['Només A', 'A ∩ B', 'Només B', 'Cap dels dos'],
          ),
          CodeStep(
            prompt:
                'Quants alumnes programen en Flutter o en Angular? |A ∪ B| = ?',
            solution: '36',
          ),
        ],
        hints: [
          "Comença pel centre: els que fan tots dos. Després, «només A» és "
              "25 menys els del centre.",
          "Principi d'inclusió-exclusió: |A ∪ B| = |A| + |B| − |A ∩ B|.",
          "Només A = 25 − 7, només B = 18 − 7. |A ∪ B| = 25 + 18 − 7 i "
              "els que no fan cap són 40 − |A ∪ B|.",
        ],
      ),
      Puzzle(
        id: '1.2',
        title: 'Les portes de De Morgan',
        source: 'Apunts FOMA · Conjunts',
        statement:
            "Una porta de la Biblioteca porta gravat: «Només passa qui "
            "no és ni d'A ni de B». És a dir, la porta s'obre amb (A ∪ B)′. "
            "Però el tauler només té fitxes de complementaris: A′ i B′.",
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
                'La segona porta demana (A ∩ B)′. Construeix-ne una '
                'expressió equivalent.',
            target: '(A∩B)′',
            solution: 'A′ ∪ B′',
            tokens: ['A′', 'B′', 'A', 'B', '∩', '∪', '(', ')'],
          ),
        ],
        hints: [
          "Pensa en un element que no és a A ∪ B. Pot ser a A? I a B?",
          "Lleis de De Morgan: el complementari intercanvia ∪ i ∩, i "
              "complementa cada conjunt.",
          "(A ∪ B)′ = A′ ∩ B′  i  (A ∩ B)′ = A′ ∪ B′.",
        ],
      ),
      Puzzle(
        id: '1.3',
        title: 'La prestatgeria',
        source: 'Apunts FOMA · Particions i relacions d\'equivalència',
        statement:
            "Els llibres numerats de l'1 al 6 s'han de guardar en tres caixes. "
            "Perquè sigui una partició, cap caixa pot quedar buida i cada "
            "llibre ha d'estar en exactament una caixa.",
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
                'Ara fes-ne una tu: arrossega els sis llibres a les tres '
                'caixes. Qualsevol partició val.',
            items: [1, 2, 3, 4, 5, 6],
            boxes: 3,
          ),
          PartitionStep(
            prompt:
                'La bibliotecària ordena per la relació a ~ b ⇔ a ≡ b (mod 3). '
                'Posa a cada caixa una classe d\'equivalència.',
            items: [1, 2, 3, 4, 5, 6],
            boxes: 3,
            target: [
              {3, 6},
              {1, 4},
              {2, 5},
            ],
            success:
                'Les classes mod 3 formen una partició: {3,6}, {1,4}, {2,5}.',
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
            "es troben els conjunts i l'aritmètica modular.",
      ),
    ],
  ),

  // ───────────────────────────── Sala 2 ─────────────────────────────
  Room(
    id: 'sala2',
    number: 2,
    name: 'La Sala dels Rellotges',
    topic: 'Aritmètica modular',
    color: AppColors.clocks,
    intro:
        "Desenes de rellotges marquen hores diferents. Cap passa de les 12: "
        "quan hi arriben, tornen a començar.",
    digit: 5,
    digitPosition: 4,
    puzzles: [
      Puzzle(
        id: '2.1',
        title: 'La taula del rellotger',
        source: 'Llista d\'exercicis · Ex. 1',
        statement:
            "Sobre el taulell hi ha la taula de multiplicar de "
            "ℤ₅ = {1, …, 5}, amb 5 ≡ 0, a mig omplir. Al costat, la de ℤ₆.",
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
                'L\'últim cadenat demana x amb 2x ≡ 1 (mod 6). Gira la roda '
                'o, si creus que no n\'hi ha cap, prem «No té solució».',
            symbols: ['1', '2', '3', '4', '5', '6'],
            solution: null,
            wheelCount: 1,
            offerNoSolution: true,
          ),
        ],
        hints: [
          "Multiplica cada fila per cada columna i queda't amb el residu en "
              "dividir per 5 (si dona 0, escriu 5).",
          "x té invers a ℤₙ si a la seva fila de la taula hi surt un 1. "
              "Això passa quan mcd(x, n) = 1.",
          "2·3 = 6 ≡ 1 (mod 5). A ℤ₆, només les files de l'1 i del 5 tenen "
              "un 1. I 2x sempre és parell: mai no pot ser ≡ 1 (mod 6).",
        ],
      ),
      Puzzle(
        id: '2.2',
        title: 'Els panys de control',
        source: 'Llista d\'exercicis · Ex. 2 i 3',
        statement:
            "Dos cadenats tanquen l'armari del rellotger. Totes les "
            "condicions són mòdul 5.",
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
        hints: [
          "Substitueix el que ja saps: a = 4 i c = 1.",
          "3b ≡ 1 vol dir que b és l'invers de 3 mòdul 5.",
          "b = 2 (3·2 = 6 ≡ 1) i d ≡ 2·4 = 8 ≡ 3. Al segon pany, X = 2.",
        ],
      ),
      Puzzle(
        id: '2.3',
        title: 'El missatge xifrat',
        source: 'Llista d\'exercicis · Ex. 5, 6, 7 i 8',
        statement:
            "Al calaix hi ha tres missatges xifrats. Fes servir "
            "l'alfabet de 27 lletres: A=0, B=1, …, N=13, Ç=14, O=15, …, Z=26.",
        theory:
            "Ex. 5 · g(x) = 2x a ℤ₇: g(3) = 6, g(5) = 3, g⁻¹(4) = 2 i "
            "g⁻¹(2) = 1. És bijectiva, però és un xifrat dolent: n'hi ha prou "
            "amb un parell (x, g(x)) per trencar-lo.",
        steps: [
          TextStep(
            prompt:
                'El missatge ERP_GLD s\'ha xifrat amb César, '
                'e(x) = x + 3 (mod 27). Gira el disc interior fins al '
                'desplaçament correcte, busca cada lletra xifrada al disc '
                'interior i llegeix la de fora. Què diu?',
            accepted: ['BON DIA'],
            aid: StepAid.caesarWheel,
          ),
          ChoiceStep(
            prompt:
                'Algú xifra les lletres A–F (A=0, …, F=5) amb '
                'e(x) = 2x + 1 (mod 6) i envia BDF. Es pot desxifrar?',
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
                'L\'últim missatge és YSFMG, xifrat amb l\'afí '
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
            "LIBRO… Potser a la Biblioteca hi ha un llibre que abans no hi era.",
      ),
    ],
  ),

  // ───────────────────────────── Sala 3 ─────────────────────────────
  Room(
    id: 'sala3',
    number: 3,
    name: 'La Torre del Dòmino',
    topic: 'Inducció matemàtica',
    color: AppColors.domino,
    intro:
        "Una escala de cargol envoltada de fitxes de dòmino dretes. "
        "Si en cau una, cauen totes… sempre que caigui la primera.",
    digit: 4,
    digitPosition: 5,
    puzzles: [
      Puzzle(
        id: '3.1',
        title: 'La prova de Bernoulli',
        source: 'Apunts FOMA · Inducció',
        statement:
            "Cal demostrar per inducció que (1 + a)ⁿ ≥ 1 + an per a "
            "tot n ≥ 0 i tot a ≥ −1.",
        steps: [
          ChoiceStep(
            prompt: 'Quin és el cas base (n = 0)?',
            options: [
              '(1+a)¹ = 1 + a ≥ 1 + a',
              '(1+a)⁰ = 1 = 1 + a·0',
              '(1+a)⁰ = 0 ≥ 0',
              'No cal cas base',
            ],
            correctIndex: 1,
          ),
          ChoiceStep(
            prompt:
                'Suposem (1+a)ᵏ ≥ 1 + ak. Per què podem multiplicar '
                'els dos costats per (1 + a) sense girar la desigualtat?',
            options: [
              'Perquè a > 0',
              'Perquè k ≥ 0',
              'Perquè a ≥ −1 ⇒ 1 + a ≥ 0',
              'Perquè (1+a)ᵏ > 0 sempre',
            ],
            correctIndex: 2,
          ),
          ChoiceStep(
            prompt:
                '(1+a)ᵏ⁺¹ ≥ (1 + ak)(1 + a) = 1 + a(k+1) + a²k. '
                'Per què podem eliminar a²k?',
            options: [
              'Perquè a²k = 0',
              'Perquè a² ≥ 0 i k ≥ 0',
              'Perquè a ≥ −1',
              'Perquè a²k < 0',
            ],
            correctIndex: 1,
          ),
        ],
        hints: [
          "Qualsevol nombre elevat a 0 dona 1.",
          "Multiplicar una desigualtat per un nombre negatiu la gira.",
          "1 + a ≥ 0 perquè a ≥ −1, i a²k ≥ 0 perquè és un quadrat per un k ≥ 0.",
        ],
      ),
      Puzzle(
        id: '3.2',
        title: 'Les torres de Hanoi',
        source: 'Apunts FOMA · Inducció i progressions geomètriques',
        statement:
            "Cal passar n discos d'una agulla a una altra, movent-ne un "
            "cada vegada i sense posar mai un disc gran sobre un de petit. "
            "M(n) és el mínim de moviments.",
        theory:
            "Per moure n discos: mou els n − 1 de dalt (M(n−1)), mou el gran "
            "(1) i torna a posar-hi els n − 1 (M(n−1)). "
            "Per tant, M(n) = 2·M(n−1) + 1, amb M(1) = 1.",
        steps: [
          CodeStep(prompt: 'Quant val M(3)?', solution: '7'),
          CodeStep(prompt: 'Quant val M(5)?', solution: '31'),
          ChoiceStep(
            prompt: 'Quina és la fórmula tancada de M(n)?',
            options: [
              'M(n) = 2ⁿ',
              'M(n) = n²',
              'M(n) = 2ⁿ − 1',
              'M(n) = 2n − 1',
            ],
            correctIndex: 2,
          ),
        ],
        hints: [
          "Calcula M(1), M(2), M(3)… amb la recurrència i busca un patró.",
          "Desplegant la recurrència surt 1 + 2 + 4 + … + 2ⁿ⁻¹: una suma "
              "geomètrica amb a₁ = 1 i r = 2.",
          "M(3) = 7, M(4) = 15, M(5) = 31. Cada valor és una potència de 2 menys 1.",
        ],
      ),
      Puzzle(
        id: '3.3',
        title: 'Els cavalls del mateix color',
        source: 'Apunts FOMA · Inducció (prova falsa)',
        statement:
            "«Tots els cavalls són del mateix color.» Prova: per a n = 1 és "
            "cert. Suposem-ho per a grups de k cavalls. En un grup de k + 1, els "
            "k primers són del mateix color, i els k últims també. Com que els "
            "dos grups comparteixen cavalls, tots k + 1 són del mateix color.",
        steps: [
          ChoiceStep(
            prompt: 'On falla la prova?',
            options: [
              'Al cas base n = 1',
              'Al pas de k = 1 a k + 1 = 2',
              'Al pas de k = 2 a k + 1 = 3',
              'La inducció no es pot fer servir amb cavalls',
            ],
            correctIndex: 1,
            success:
                "Amb k + 1 = 2, els grups són {c₁} i {c₂}: no comparteixen "
                "cap cavall, i la cadena es trenca.",
          ),
        ],
        hints: [
          "El cas base és cert. El problema és en algun pas concret.",
          "El pas inductiu ha de funcionar per a tot k ≥ 1, també per al més petit.",
          "Prova-ho amb k + 1 = 2: quins són els «k primers» i els «k últims»?",
        ],
      ),
    ],
  ),
];

/// La porta d'Euler (Ex. 4). El pany «a 3 c 5 4» viu a ℤ₇ = {1, …, 7}.
const Puzzle finalPuzzle = Puzzle(
  id: 'porta',
  title: "La porta d'Euler",
  source: 'Llista d\'exercicis · Ex. 4',
  statement:
      "El pany «a 3 c 5 4» funciona a ℤ₇ = {1, …, 7}. Ja tens les xifres de "
      "les sales, però falten a i c. Les condicions que han de complir no són "
      "a la porta: Euler les va amagar en un llibre.",
  steps: [
    CodeStep(prompt: 'Quant val a?', solution: '5'),
    CodeStep(prompt: 'Quant val c?', solution: '5'),
    CodeStep(prompt: 'Introdueix el codi complet del pany.', solution: '53554'),
  ],
  hints: [
    "a és el nombre que multiplicat per 3 dona 1 mòdul 7.",
    "Prova els valors de l'1 al 7. Per a c, calcula 5c mod 7 fins que doni 4.",
    "3·5 = 15 ≡ 1 i 5·5 = 25 ≡ 4 (mod 7). El codi és a 3 c 5 4.",
  ],
);

/// El llibre amagat: apareix a la Biblioteca quan es resol el puzle 2.3
/// («LIBRO») i conté les condicions de la porta.
const String secretBookUnlockedBy = '2.3';
const String secretBookRoom = 'sala1';
const String secretBookTitle = 'Un llibre que brilla';
const String secretBookText =
    "Entre dos volums de Venn hi ha un quadern d'Euler que abans no hi era. "
    "A l'última pàgina hi diu:\n\n«a és l'invers de 3; c·5 ≡ 4, a ℤ₇.»";
const String secretBookMissing =
    "Encara no has trobat on són escrites les condicions. Potser el missatge "
    "xifrat de la Sala dels Rellotges diu on buscar…";

/// Tots els puzles, inclosa la porta, indexats per id.
final Map<String, Puzzle> puzzlesById = {
  for (final r in rooms)
    for (final p in r.puzzles) p.id: p,
  finalPuzzle.id: finalPuzzle,
};
