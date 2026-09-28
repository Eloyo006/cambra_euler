import '../core/rng.dart';
import '../core/theme.dart';
import '../models/puzzle.dart';
import 'variation.dart';

/// Sala 3 · La Torre del Dòmino: inducció (apunts FOMA).
Room buildSala3(Variation v) => Room(
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
    _bernoulli(v.rng('3.1')),
    _hanoi(v.rng('3.2')),
    _cavalls(v.rng('3.3')),
    _divisibilitat(v.rng('3.4')),
  ],
);

/// 3.1 · Prova de Bernoulli.
Puzzle _bernoulli(Rng r) => const Puzzle(
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
);

/// 3.2 · Torres de Hanoi.
Puzzle _hanoi(Rng r) => const Puzzle(
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
      options: ['M(n) = 2ⁿ', 'M(n) = n²', 'M(n) = 2ⁿ − 1', 'M(n) = 2n − 1'],
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
);

/// 3.3 · Cavalls del mateix color.
Puzzle _cavalls(Rng r) => const Puzzle(
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
);

/// 3.4 · Divisibilitat (bonus, ex. 11 i 30).
Puzzle _divisibilitat(Rng r) => const Puzzle(
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
    CodeStep(prompt: 'Ex. 30 · Quant val 3⁴ = 81 mòdul 10?', solution: '1'),
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
);
