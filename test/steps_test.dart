// Un test per al validador `check()` de cada tipus de pas.
import 'package:cambra_euler/models/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('CodeStep', () {
    const s = CodeStep(prompt: '', solution: '4213');
    test('accepta el codi, amb espais o guions', () {
      expect(s.check('4213'), isTrue);
      expect(s.check(' 4 2-1_3 '), isTrue);
    });
    test('rebutja codis dolents i tipus incorrectes', () {
      expect(s.check('4231'), isFalse);
      expect(s.check(4213), isFalse);
    });
  });

  group('TextStep', () {
    const s = TextStep(prompt: '', accepted: ['BON DIA']);
    test('ignora majúscules, accents, _ i espais repetits', () {
      expect(s.check('bon dia'), isTrue);
      expect(s.check('  Bón   DÍA '), isTrue);
      expect(s.check('BON_DIA'), isTrue);
    });
    test('rebutja altres textos', () {
      expect(s.check('BONDIA'), isFalse);
      expect(s.check(1), isFalse);
    });
    test('la Ç no es normalitza a C', () {
      expect(TextStep.normalizeText('ç'), 'Ç');
    });
  });

  group('ChoiceStep', () {
    const s = ChoiceStep(prompt: '', options: ['a', 'b', 'c'], correctIndex: 1);
    test('només l\'índex correcte', () {
      expect(s.check(1), isTrue);
      expect(s.check(0), isFalse);
      expect(s.check('1'), isFalse);
      expect(s.solutionLabel, 'b');
    });
  });

  group('TableStep', () {
    const s = TableStep(prompt: '', modulus: 5, prefilled: [1, 5, 7]);
    test('notació {1..n}: la fila 5 i la columna 5 valen 5 (≡ 0)', () {
      expect(s.cell(4, 4), 5);
      expect(s.cell(1, 2), 1); // 2·3 = 6 ≡ 1
      expect(s.cell(0, 1), 2);
    });
    test('accepta la taula completa', () {
      expect(s.check(s.solution), isTrue);
    });
    test('rebutja una casella dolenta o una mida incorrecta', () {
      final bad = List.of(s.solution)..[12] = 1;
      expect(s.check(bad), isFalse);
      expect(s.check(s.solution.sublist(1)), isFalse);
    });
  });

  group('TableStep (modes)', () {
    const mark = TableStep(prompt: '', modulus: 5, mode: TableMode.markCells);
    const pick = TableStep(
      prompt: '',
      modulus: 6,
      mode: TableMode.pickInvertible,
    );
    test('marcar els 1: exactament les caselles que valen 1', () {
      expect(mark.markedCells, {0, 7, 11, 18});
      expect(mark.check({0, 7, 11, 18}), isTrue);
      expect(mark.check({0, 7, 11}), isFalse);
      expect(mark.check({0, 7, 11, 18, 24}), isFalse);
      expect(mark.check([0, 7, 11, 18]), isFalse);
    });
    test('invertibles de ℤ₆ = {1, 5}', () {
      expect(pick.check({5, 1}), isTrue);
      expect(pick.check({1}), isFalse);
      expect(pick.check({1, 5, 6}), isFalse);
      expect(pick.solutionLabel, '1 i 5');
    });
    test('invertibles de ℤ₅ i ℤ₇: tots menys n', () {
      const z5 = TableStep(
        prompt: '',
        modulus: 5,
        mode: TableMode.pickInvertible,
      );
      const z7 = TableStep(
        prompt: '',
        modulus: 7,
        mode: TableMode.pickInvertible,
      );
      expect(z5.invertibles, {1, 2, 3, 4});
      expect(z7.invertibles, {1, 2, 3, 4, 5, 6});
    });
  });

  group('WheelLockStep sense solució', () {
    const s = WheelLockStep(
      prompt: '',
      symbols: ['1', '2', '3', '4', '5', '6'],
      solution: null,
      wheelCount: 1,
      offerNoSolution: true,
    );
    test('només el botó «No té solució» és correcte', () {
      expect(s.check(WheelLockStep.noSolution), isTrue);
      for (final v in s.symbols) {
        expect(s.check([v]), isFalse);
      }
      expect(s.wheels, 1);
    });
    test('amb solució, «No té solució» és incorrecte', () {
      const t = WheelLockStep(prompt: '', symbols: ['0', '1'], solution: ['1']);
      expect(t.check(WheelLockStep.noSolution), isFalse);
    });
  });

  group('TextStep amb ajuda', () {
    test('l\x27ajuda afí es desbloqueja amb la pista 2', () {
      const s = TextStep(
        prompt: '',
        accepted: ['LIBRO'],
        aid: StepAid.affineTable,
        aidMinHints: 2,
      );
      expect(s.showsAid(0), isFalse);
      expect(s.showsAid(1), isFalse);
      expect(s.showsAid(2), isTrue);
      const plain = TextStep(prompt: '', accepted: ['x']);
      expect(plain.showsAid(3), isFalse);
    });
  });

  group('VennStep', () {
    const s = VennStep(prompt: '', regions: [18, 7, 11, 4]);
    test('accepta les quatre regions correctes', () {
      expect(s.check([18, 7, 11, 4]), isTrue);
    });
    test('rebutja errors i marca les regions bones', () {
      expect(s.check([18, 7, 11, 5]), isFalse);
      expect(s.check([25, 18, 7, 40]), isFalse);
      expect(s.correctRegions([18, null, 11, 0]), [true, false, true, false]);
    });
  });

  group('ExpressionStep', () {
    const s = ExpressionStep(prompt: '', target: '(A∪B)′', solution: 'A′ ∩ B′');
    test('accepta qualsevol expressió equivalent', () {
      expect(s.check('A′ ∩ B′'), isTrue);
      expect(s.check(['B′', '∩', 'A′']), isTrue);
      expect(s.check(['(', 'A′', '∩', 'B′', ')']), isTrue);
      expect(s.check("(A'∩B')"), isTrue);
    });
    test('rebutja expressions no equivalents o mal formades', () {
      expect(s.check('A′ ∪ B′'), isFalse);
      expect(s.check(['A′', '∩']), isFalse);
      expect(s.check(['(', 'A']), isFalse);
      expect(s.check(42), isFalse);
    });
    test('copiar l\'enunciat literalment no val', () {
      expect(s.check('(A∪B)′'), isFalse);
      expect(s.check(['(', 'A', '∪', 'B', ')', '′']), isFalse);
    });
  });

  group('PartitionStep', () {
    const any = PartitionStep(prompt: '', items: [1, 2, 3, 4, 5, 6], boxes: 3);
    const mod3 = PartitionStep(
      prompt: '',
      items: [1, 2, 3, 4, 5, 6],
      boxes: 3,
      target: [
        {3, 6},
        {1, 4},
        {2, 5},
      ],
    );
    test('qualsevol partició en 3 caixes no buides', () {
      expect(
        any.check([
          {1, 3, 5},
          {2, 4},
          {6},
        ]),
        isTrue,
      );
      expect(
        any.check([
          {1},
          {2},
          {3, 4, 5, 6},
        ]),
        isTrue,
      );
    });
    test(
      'rebutja caixes buides, repetits, oblidats o nombre de caixes dolent',
      () {
        expect(
          any.check([
            {1, 2, 3, 4, 5, 6},
            <int>{},
            <int>{},
          ]),
          isFalse,
        );
        expect(
          any.check([
            {1, 3, 5},
            {2, 4, 5},
            {6},
          ]),
          isFalse,
        );
        expect(
          any.check([
            {1, 3},
            {2, 4},
            {6},
          ]),
          isFalse,
        );
        expect(
          any.check([
            {1, 3, 5},
            {2, 4, 6},
          ]),
          isFalse,
        );
      },
    );
    test('classes mod 3 en qualsevol ordre de caixes', () {
      expect(
        mod3.check([
          {2, 5},
          {3, 6},
          {4, 1},
        ]),
        isTrue,
      );
      expect(
        mod3.check([
          {1, 3, 5},
          {2, 4},
          {6},
        ]),
        isFalse,
      );
      expect(mod3.solutionLabel, '{3,6}, {1,4}, {2,5}');
    });
  });

  group('OrderStep', () {
    const s = OrderStep(
      prompt: '',
      lines: ['a', 'b', 'c'],
      initialOrder: [2, 0, 1],
    );
    test('només l\'ordre correcte', () {
      expect(s.check([0, 1, 2]), isTrue);
      expect(s.check(s.initialOrder), isFalse);
      expect(s.check([0, 1]), isFalse);
    });
  });

  group('HanoiStep', () {
    const s3 = HanoiStep(prompt: '', discs: 3);
    const s4 = HanoiStep(prompt: '', discs: 4);
    test('mínim 2ⁿ − 1', () {
      expect(s3.minMoves, 7);
      expect(s4.minMoves, 15);
    });
    test('accepta la solució òptima', () {
      expect(s3.check(hanoiSolution(3)), isTrue);
      expect(s4.check(hanoiSolution(4)), isTrue);
    });
    test('rebutja moviments il·legals', () {
      // Disc 2 sobre el disc 1.
      expect(s3.play([(0, 2), (0, 2)]), isNull);
      expect(HanoiStep.isLegal(s3.initial, (1, 2)), isFalse); // agulla buida
    });
    test('rebutja solucions no mínimes o incompletes', () {
      final long = [(0, 1), (1, 0), ...hanoiSolution(3)];
      expect(s3.play(long), isNotNull);
      expect(s3.isDone(s3.play(long)!), isTrue);
      expect(s3.check(long), isFalse);
      expect(s3.check(hanoiSolution(2)), isFalse);
    });
  });

  group('TapLineStep', () {
    const s = TapLineStep(prompt: '', lines: ['x', 'y', 'z'], wrongLine: 2);
    test('només la línia que falla', () {
      expect(s.check(2), isTrue);
      expect(s.check(0), isFalse);
      expect(s.solutionLabel, 'z');
    });
  });

  group('WheelLockStep', () {
    const s = WheelLockStep(
      prompt: '',
      symbols: ['1', '2', '3', '4', '5', '6', '7'],
      solution: ['5', '3', '5', '5', '4'],
      locked: [1, 3, 4],
    );
    test('accepta la combinació', () {
      expect(s.check(['5', '3', '5', '5', '4']), isTrue);
      expect(s.solutionLabel, '5 3 5 5 4');
    });
    test('rebutja combinacions dolentes', () {
      expect(s.check(['1', '3', '5', '5', '4']), isFalse);
      expect(s.check(['5', '3', '5', '5']), isFalse);
      expect(s.check('53554'), isFalse);
    });
  });

  test('solutionOf dona una resposta vàlida per a cada tipus', () {
    const steps = <PuzzleStep>[
      CodeStep(prompt: '', solution: '7'),
      TextStep(prompt: '', accepted: ['i']),
      ChoiceStep(prompt: '', options: ['a', 'b'], correctIndex: 0),
      TableStep(prompt: '', modulus: 6, prefilled: []),
      VennStep(prompt: '', regions: [1, 2, 3, 4]),
      ExpressionStep(prompt: '', target: '(A∩B)′', solution: 'A′ ∪ B′'),
      PartitionStep(prompt: '', items: [1, 2, 3, 4], boxes: 3),
      OrderStep(prompt: '', lines: ['a', 'b'], initialOrder: [1, 0]),
      HanoiStep(prompt: '', discs: 4),
      TapLineStep(prompt: '', lines: ['a'], wrongLine: 0),
      WheelLockStep(prompt: '', symbols: ['a', 'e'], solution: ['e', 'a']),
    ];
    for (final s in steps) {
      expect(s.check(solutionOf(s)), isTrue, reason: s.runtimeType.toString());
    }
  });
}
