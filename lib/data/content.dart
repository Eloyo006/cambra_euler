import '../core/theme.dart';
import '../models/puzzle.dart';

/// Tot el contingut del joc. Els enunciats són fixos (no aleatoris).
/// Les solucions es verifiquen a `test/content_test.dart`.

const List<int> hintPenalties = [30, 60, 120];
const List<String> hintLabels = ['Suggeriment', 'Teoria', 'Gairebé la solució'];

const String introText =
    "Sant Petersburg, 18 de setembre de 1783. Leonhard Euler ha mort aquesta "
    "tarda, i tu, el seu ajudant, ets l'única persona que queda a la casa.\n\n"
    "A la seva cambra de treball hi ha l'últim manuscrit d'Euler. A trenc "
    "d'alba, l'Acadèmia de Ciències vindrà a segellar-la, i ningú no el "
    "tornarà a llegir. La porta té un pany de cinc xifres. Només s'hi llegeix "
    "«a 3 c 5 4».\n\n"
    "Els últims anys, Euler ja no hi veia, i ho guardava tot al cap. Va "
    "amagar cada xifra que falta en una sala de la casa i hi va deixar "
    "enigmes, perquè només pogués entrar qui els entengués: la Biblioteca "
    "(conjunts), la Sala dels Rellotges (aritmètica modular) i la Torre del "
    "Dòmino (inducció). Les dues lletres, a i c, les hauràs de calcular tu.\n\n"
    "La nit s'acaba. Cada pista que demanis t'acosta a l'alba.";

/// Resum curt per a la portada; la història sencera és a [introText].
const String homeBlurb =
    "Sant Petersburg, 1783. Euler acaba de morir, i a trenc d'alba "
    "l'Acadèmia segellarà la seva cambra de treball. Tens una nit per trobar "
    "les xifres del pany «a 3 c 5 4» i salvar-ne l'últim manuscrit.";

const String victoryText =
    "La porta cedeix. Sobre la taula, entre espelmes consumides, hi ha el "
    "manuscrit i una nota amb la lletra tremolosa d'Euler:\n\n"
    "«Si llegeixes això, has entès que els conjunts, els residus i la "
    "inducció són una mateixa manera de pensar. Continua tu el que jo no he "
    "pogut acabar.»\n\n"
    "Just quan surts amb el manuscrit sota el braç, se sent la carrossa de "
    "l'Acadèmia. «Llegiu Euler, llegiu Euler: és el mestre de tots "
    "nosaltres.»";

const List<Room> rooms = [
  // ───────────────────────────── Sala 1 ─────────────────────────────
  Room(
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
      Puzzle(
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
            prompt:
                'Toca cada regió del diagrama i escriu-hi quants lectors hi ha.',
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
      ),
      Puzzle(
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
      ),
      Puzzle(
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
            "es troben els conjunts i l'aritmètica modular. Quan l'últim "
            "volum encaixa, el calaix del mig s'obre sol. Al fons hi ha una "
            "fitxa de fusta amb un 3 gravat.",
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
        "Desenes de rellotges, i cap no marca la mateixa hora. Euler deia que "
        "el temps és el millor exemple de residu: quan arriba a les 12, torna "
        "a començar. El rellotger de la casa hi va deixar la feina a mitges…",
    digit: 5,
    digitPosition: 4,
    puzzles: [
      Puzzle(
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
      ),
      Puzzle(
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
      ),
      Puzzle(
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
        "Una escala de cargol puja fins a l'observatori. Els néts d'Euler hi "
        "van posar fitxes de dòmino dretes a cada graó. «Si en cau una, "
        "cauen totes», els deia l'avi, «sempre que caigui la primera.» Cada "
        "replà és tancat amb una trapa.",
    digit: 4,
    digitPosition: 5,
    puzzles: [
      Puzzle(
        id: '3.1',
        title: 'La prova de Bernoulli',
        source: 'Apunts FOMA · Inducció',
        statement:
            "Al primer replà, sobre un faristol, hi ha la prova que Euler "
            "feia copiar als néts: per inducció, (1 + a)ⁿ ≥ 1 + an per a "
            "tot n ≥ 0 i tot a ≥ −1. El corrent d'aire de l'escala n'ha "
            "barrejat els fulls, i la trapa no s'obrirà fins que la prova "
            "torni a estar en ordre.",
        steps: [
          OrderStep(
            prompt:
                'Arrossega les línies (per la maneta de la dreta) fins que '
                'la prova quedi en ordre.',
            lines: [
              'Cas base (n = 0): (1+a)⁰ = 1 = 1 + a·0.',
              "Hipòtesi d'inducció: (1+a)ᵏ ≥ 1 + ak per a un cert k ≥ 0.",
              'Multipliquem per (1 + a) ≥ 0: (1+a)ᵏ⁺¹ ≥ (1 + ak)(1 + a).',
              'Desenvolupem: (1 + ak)(1 + a) = 1 + a(k+1) + a²k.',
              'Eliminem a²k ≥ 0: 1 + a(k+1) + a²k ≥ 1 + a(k+1).',
              'Conclusió: (1+a)ᵏ⁺¹ ≥ 1 + a(k+1). Per inducció, val per a tot n ≥ 0.',
            ],
            initialOrder: [3, 0, 5, 2, 4, 1],
            success: 'Totes les fitxes cauen: la prova està en ordre!',
            celebration: Celebration.dominoes,
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
        outro:
            "Les fitxes cauen escala amunt, una rere l'altra, i l'última "
            "empeny la trapa del segon replà.",
        hints: [
          "Una prova per inducció sempre comença pel cas base i acaba amb "
              "la conclusió. Entremig: hipòtesi → pas → càlcul.",
          "Multiplicar una desigualtat per un nombre negatiu la gira. "
              "Un quadrat mai no és negatiu.",
          "Ordre: cas base, hipòtesi, multiplicar, desenvolupar, eliminar a²k, "
              "conclusió. 1 + a ≥ 0 perquè a ≥ −1, i a²k ≥ 0.",
        ],
      ),
      Puzzle(
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
          HanoiStep(
            prompt:
                'Toca una agulla per agafar el disc de dalt i una altra per '
                'deixar-lo. Primer, amb 3 discos i el mínim de moviments.',
            discs: 3,
            success: 'M(3) = 7.',
          ),
          HanoiStep(
            prompt: 'Ara amb 4 discos, també amb el mínim de moviments.',
            discs: 4,
            success: 'M(4) = 15 = 2·7 + 1.',
          ),
          CodeStep(prompt: 'Sense jugar: quant val M(5)?', solution: '31'),
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
        outro:
            "El contrapès baixa i la trapa s'obre. Hanoi també és una suma "
            "geomètrica: 1 + 2 + 4 + … + 2ⁿ⁻¹ = 2ⁿ − 1.",
        hints: [
          "Amb 3 discos: porta els 2 petits a l'agulla del mig, mou el gran a "
              "la dreta i torna a posar-hi els 2 petits a sobre.",
          "Desplegant la recurrència surt 1 + 2 + 4 + … + 2ⁿ⁻¹: una suma "
              "geomètrica amb a₁ = 1 i r = 2.",
          "M(3) = 7, M(4) = 15, M(5) = 2·15 + 1 = 31. Cada valor és una "
              "potència de 2 menys 1.",
        ],
      ),
      Puzzle(
        id: '3.3',
        title: 'Els cavalls del mateix color',
        source: 'Apunts FOMA · Inducció (prova falsa)',
        statement:
            "A l'observatori, al costat del telescopi, hi ha el quadern d'un "
            "deixeble massa confiat que «demostra» per inducció que tots els "
            "cavalls són del mateix color. Al marge, amb la lletra d'Euler: "
            "«Troba on falla i tindràs l'última xifra.»",
        steps: [
          TapLineStep(
            prompt: 'Toca la línia on falla la prova.',
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
            success:
                'Aquesta és la línia: els dos grups no sempre comparteixen '
                'cavalls.',
            celebration: Celebration.disjointHorses,
          ),
          ChoiceStep(
            prompt: 'Per a quin pas concret falla?',
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
        outro:
            "Quan passes el full, dins de la tapa del quadern hi ha un 4 "
            "escrit en tinta vermella. Per la finestra de l'observatori, el "
            "cel ja comença a clarejar.",
        hints: [
          "El cas base és cert. El problema és en algun pas concret.",
          "El pas inductiu ha de funcionar per a tot k ≥ 1, també per al més petit.",
          "Prova-ho amb k + 1 = 2: quins són els «k primers» i els «k últims»? "
              "Tenen algun cavall en comú?",
        ],
      ),
      Puzzle(
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
            "Ex. 11: 5ⁿ + 1 és divisible per 2 però no per 4.\n"
            "Ex. 30: 3⁴ⁿ + 9 és múltiple de 10.",
        steps: [
          CodeStep(prompt: 'Ex. 11 · Quant val 5 mòdul 4?', solution: '1'),
          CodeStep(
            prompt:
                'Si 5ᵏ ≡ 1 (mod 4), llavors 5ᵏ⁺¹ = 5·5ᵏ ≡ 1. Per tant, '
                'quant val 5ⁿ + 1 mòdul 4?',
            solution: '2',
            success: '5ⁿ + 1 ≡ 2 (mod 4): és parell, però no és múltiple de 4.',
          ),
          CodeStep(
            prompt: 'Ex. 30 · Quant val 3⁴ = 81 mòdul 10?',
            solution: '1',
          ),
          ChoiceStep(
            prompt:
                'Pas inductiu: si 3⁴ᵏ + 9 ≡ 0 (mod 10), per què també '
                '3⁴⁽ᵏ⁺¹⁾ + 9 ≡ 0 (mod 10)?',
            options: [
              'Perquè 3⁴⁽ᵏ⁺¹⁾ = 81·3⁴ᵏ ≡ 1·3⁴ᵏ (mod 10)',
              'Perquè 3 i 10 no tenen divisors comuns',
              'Perquè 81 és un quadrat perfecte',
              'Perquè 9 és senar',
            ],
            correctIndex: 0,
            success: '3⁴ⁿ + 9 ≡ 1 + 9 ≡ 0 (mod 10). Bonus aconseguit: −60 s!',
          ),
        ],
        hints: [
          "Treballa amb residus: només importa el residu de 5 (o de 81) en "
              "dividir.",
          "Si a ≡ 1 (mod m), aleshores aᵏ ≡ 1ᵏ = 1 (mod m): es demostra per "
              "inducció multiplicant per a a cada pas.",
          "5 ≡ 1 (mod 4), així que 5ⁿ + 1 ≡ 2. I 81 ≡ 1 (mod 10), així que "
              "3⁴ⁿ + 9 ≡ 1 + 9 ≡ 0.",
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

/// El llibre amagat: apareix a la Biblioteca quan es resol el puzle 2.3
/// («LIBRO») i conté les condicions de la porta.
const String secretBookUnlockedBy = '2.3';
const String secretBookRoom = 'sala1';
const String secretBookTitle = 'Un llibre que brilla';
const String secretBookText =
    "Al calaix del mig de la prestatgeria, darrere dels sis volums, hi ha un "
    "quadern petit que brilla a la llum de l'espelma. És el quadern de "
    "butxaca d'Euler. A l'última pàgina, amb la lletra que li quedava quan "
    "ja no hi veia:\n\n«a és l'invers de 3; c·5 ≡ 4, a ℤ₇.»";
const String secretBookMissing =
    "Encara no has trobat on són escrites les condicions. Potser les cartes "
    "xifrades de la Sala dels Rellotges diuen on buscar…";

/// Tots els puzles, inclosa la porta, indexats per id.
final Map<String, Puzzle> puzzlesById = {
  for (final r in rooms)
    for (final p in r.puzzles) p.id: p,
  finalPuzzle.id: finalPuzzle,
};
