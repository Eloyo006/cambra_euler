// Verifica matemàticament totes les solucions de la §4 del brief.
import 'package:cambra_euler/core/modular.dart';
import 'package:cambra_euler/core/set_expr.dart';
import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/models/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Puzzle p(String id) => puzzlesById[id]!;

void main() {
  group('Estructura', () {
    test('3 sales amb 3 puzles obligatoris, 3 pistes cadascun', () {
      expect(rooms, hasLength(3));
      for (final r in rooms) {
        expect(r.puzzles.where((pz) => !pz.optional), hasLength(3));
      }
      for (final pz in puzzlesById.values) {
        expect(pz.hints, hasLength(3), reason: pz.id);
        expect(pz.steps, isNotEmpty, reason: pz.id);
      }
      expect(hintPenalties, [30, 60, 120]);
      expect(hintLabels, hasLength(3));
    });

    test('ids únics', () {
      final ids = [for (final r in rooms) ...r.puzzles.map((x) => x.id)];
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('opcions de resposta vàlides', () {
      for (final pz in puzzlesById.values) {
        for (final s in pz.steps.whereType<ChoiceStep>()) {
          expect(s.correctIndex, inInclusiveRange(0, s.options.length - 1));
          expect(s.options.toSet(), hasLength(s.options.length));
        }
      }
    });

    test('el pany: sales → 3 (pos 2), 5 (pos 4), 4 (pos 5)', () {
      expect(
        [for (final r in rooms) (r.digit, r.digitPosition)],
        [(3, 2), (5, 4), (4, 5)],
      );
    });
  });

  group('Variants', () {
    // Moltes llavors: cobreix totes les combinacions de variants probables.
    final seeds = [for (var s = 0; s < 200; s++) s * 7919];
    List<String> ids(GameContent c) => [
      for (final r in c.rooms) ...r.puzzles.map((x) => x.id),
      c.finalPuzzle.id,
    ];

    test('la mateixa llavor genera el mateix contingut', () {
      final a = GameContent.forSeed(99);
      GameContent.forSeed(100); // buida la memòria cau
      final b = GameContent.forSeed(99);
      expect(ids(b), ids(a));
      for (final id in a.puzzlesById.keys) {
        expect(b.puzzlesById[id]!.statement, a.puzzlesById[id]!.statement);
      }
      expect(b.secretBookText, a.secretBookText);
    });

    test('totes les llavors tenen els mateixos puzles i sales', () {
      // El progrés desat va per id: no pot dependre de la variant.
      final base = ids(testContent);
      for (final seed in seeds) {
        final c = GameContent.forSeed(seed);
        expect(ids(c), base, reason: 'llavor $seed');
        expect(
          [for (final r in c.rooms) r.id],
          ['sala1', 'sala2', 'sala3'],
          reason: 'llavor $seed',
        );
        expect(
          c.puzzlesById[secretBookUnlockedBy],
          isNotNull,
          reason: 'llavor $seed',
        );
      }
    });

    test('les variants existeixen de veritat (no surt sempre la mateixa)', () {
      // «Empremta» d'un puzle: enunciat, preguntes, solucions i ordres.
      String order(PuzzleStep s) => switch (s) {
        ChoiceStep c => c.options.join('|'),
        OrderStep o => o.initialOrder.join(','),
        _ => '',
      };
      String print(Puzzle pz) => [
        pz.statement,
        for (final s in pz.steps) '${s.prompt}|${s.solutionLabel}|${order(s)}',
      ].join('\n');
      for (final id in [
        ...['1.1', '1.2', '1.3', '2.1', '2.2', '2.3'],
        ...['3.1', '3.2', '3.3', '3.4', 'porta'],
      ]) {
        final prints = {
          for (final seed in seeds)
            print(GameContent.forSeed(seed).puzzlesById[id]!),
        };
        expect(prints.length, greaterThan(1), reason: id);
      }
    });

    test('a cada llavor, les opcions són diferents i vàlides', () {
      for (final seed in seeds) {
        final c = GameContent.forSeed(seed);
        for (final pz in c.puzzlesById.values) {
          for (final s in pz.steps.whereType<ChoiceStep>()) {
            expect(
              s.correctIndex,
              inInclusiveRange(0, s.options.length - 1),
              reason: '${pz.id} · llavor $seed',
            );
            expect(
              s.options.toSet(),
              hasLength(s.options.length),
              reason: '${pz.id} · llavor $seed',
            );
          }
        }
      }
    });

    test('1.1: totes les regions tenen gent i la unió quadra', () {
      for (final seed in seeds) {
        final pz = GameContent.forSeed(seed).puzzlesById['1.1']!;
        final venn = pz.steps[0] as VennStep;
        final union = pz.steps[1] as CodeStep;
        expect(venn.regions.every((n) => n > 0), isTrue, reason: '$seed');
        expect(
          union.solution,
          '${venn.regions[0] + venn.regions[1] + venn.regions[2]}',
        );
        // Els números de l'enunciat: total, A, B, A∩B.
        final total = venn.regions.reduce((a, b) => a + b);
        expect(pz.statement, contains('«$total lectors'));
      }
    });

    test('1.2: la resposta és equivalent i no és una còpia', () {
      for (final seed in seeds) {
        final pz = GameContent.forSeed(seed).puzzlesById['1.2']!;
        for (final s in pz.steps.cast<ExpressionStep>()) {
          expect(setExprEquivalent(s.solution, s.target), isTrue);
          expect(s.solution.contains('('), isFalse);
          expect(pz.hints[2], contains(s.solution));
        }
      }
    });

    test('1.3: només una opció és una partició i només una és [k]', () {
      List<Set<int>> parse(String option) => [
        for (final m in RegExp(r'\{([^}]*)\}|∅').allMatches(option))
          m.group(0) == '∅'
              ? <int>{}
              : {for (final x in m.group(1)!.split(',')) int.parse(x.trim())},
      ];
      for (final seed in seeds) {
        final pz = GameContent.forSeed(seed).puzzlesById['1.3']!;
        final test = pz.steps[0] as ChoiceStep;
        final items = (pz.steps[1] as PartitionStep).items;
        final valid = [
          for (var i = 0; i < test.options.length; i++)
            if (PartitionStep.isPartition(parse(test.options[i]), items)) i,
        ];
        expect(valid, [test.correctIndex], reason: 'llavor $seed');

        final classes = (pz.steps[2] as PartitionStep).target!;
        final q = pz.steps[3] as ChoiceStep;
        final k = int.parse(RegExp(r'\[(\d+)\]').firstMatch(q.prompt)![1]!);
        final right = classes.firstWhere((c) => c.contains(k));
        final matching = [
          for (var i = 0; i < q.options.length; i++)
            if (parse(q.options[i]).single.length == right.length &&
                parse(q.options[i]).single.containsAll(right))
              i,
        ];
        expect(matching, [q.correctIndex], reason: 'llavor $seed');
        // Les classes són les de mod 3.
        for (final c in classes) {
          expect(c.map((x) => x % 3).toSet(), hasLength(1));
        }
      }
    });

    List<int> nums(String s, String pattern) => [
      for (final g in RegExp(pattern).firstMatch(s)!.groups([1, 2]))
        int.parse(g!),
    ];

    test('2.1: l\'invers és correcte i l\'equació no té solució', () {
      for (final seed in seeds) {
        final pz = GameContent.forSeed(seed).puzzlesById['2.1']!;
        final q = pz.steps[2] as CodeStep;
        final k = int.parse(
          RegExp(r'invers de (\d)').firstMatch(q.prompt)![1]!,
        );
        expect(mod(k * int.parse(q.solution), 5), 1, reason: '$seed');
        final lock = pz.steps[4] as WheelLockStep;
        final [a, b] = nums(lock.prompt, r'(\d)x ≡ (\d) \(mod 6\)');
        expect(solveLinear(a, b, 6), isEmpty, reason: '$a x ≡ $b');
        expect(lock.solution, isNull);
      }
    });

    test('2.2: els panys compleixen les congruències i són únics', () {
      for (final seed in seeds) {
        final pz = GameContent.forSeed(seed).puzzlesById['2.2']!;
        final l1 = pz.steps[0] as WheelLockStep;
        final [a, b, c, d] = l1.solution!.map(int.parse).toList();
        final [p, _] = nums(l1.prompt, r'(\d)b ≡ c i (\d)a');
        final [_, q] = nums(l1.prompt, r'(\d)b ≡ c i (\d)a');
        expect(mod(p * b - c, 5), 0, reason: '$seed');
        expect(mod(q * a - d, 5), 0, reason: '$seed');
        expect(solveLinear(p, c, 5), [b]);
        expect(b, lessThan(5));
        expect(d, lessThan(5));

        final l2 = pz.steps[1] as WheelLockStep;
        final [k, m] = nums(l2.prompt, r'(\d)X ≡ (\d) \(mod 5\)');
        final x = l2.symbols.indexOf(l2.solution!.last);
        expect(solveLinear(k, m, 5), [x], reason: '$seed');
      }
    });

    test('2.3: els tres xifrats es desxifren bé', () {
      for (final seed in seeds) {
        final pz = GameContent.forSeed(seed).puzzlesById['2.3']!;
        // César.
        final cesar = pz.steps[0] as TextStep;
        final cm = RegExp(
          r'diu (\S+), xifrat.*x \+ (\d+) \(mod 27\)',
        ).firstMatch(cesar.prompt)!;
        expect(
          affineDecrypt(cm[1]!.replaceAll('_', ' '), 1, int.parse(cm[2]!)),
          cesar.accepted.first,
          reason: '$seed',
        );
        // Mòdul 6: cada lletra enviada té més d'un origen.
        final q = pz.steps[1] as ChoiceStep;
        final qm = RegExp(
          r'e\(x\) = (\d)x \+ (\d) \(mod 6\) i envia (\w+)',
        ).firstMatch(q.prompt)!;
        final a6 = int.parse(qm[1]!), b6 = int.parse(qm[2]!);
        for (final ch in qm[3]!.split('')) {
          final y = alphabet27.indexOf(ch);
          final origins = [
            for (var x = 0; x < 6; x++)
              if (mod(a6 * x + b6, 6) == y) x,
          ];
          expect(origins.length, greaterThan(1), reason: '$seed $ch');
          expect(q.solutionLabel, contains('${origins.length} orígens'));
        }
        // Afí.
        final af = pz.steps[2] as TextStep;
        final am = RegExp(
          r': (\S+), xifrat.*e\(x\) = (\d+)x \+ (\d+).*és (\d+)\.',
        ).firstMatch(af.prompt)!;
        final ka = int.parse(am[2]!), kb = int.parse(am[3]!);
        expect(mod(ka * int.parse(am[4]!), 27), 1, reason: 'invers $seed');
        expect(affineDecrypt(am[1]!, ka, kb), af.accepted.first);
        expect(af.affine, (a: ka, b: kb));
        expect(pz.outro, startsWith(af.accepted.first));
      }
    });

    test('3.1 i 3.2: prova desordenada i M(k) = 2ᵏ − 1', () {
      for (final seed in seeds) {
        final c = GameContent.forSeed(seed);
        final order = c.puzzlesById['3.1']!.steps[0] as OrderStep;
        expect([...order.initialOrder]..sort(), [
          for (var i = 0; i < order.lines.length; i++) i,
        ]);
        expect(order.check(order.initialOrder), isFalse, reason: '$seed');

        final q = c.puzzlesById['3.2']!.steps[2] as CodeStep;
        final k = int.parse(RegExp(r'M\((\d)\)').firstMatch(q.prompt)![1]!);
        expect(q.solution, '${(1 << k) - 1}');
      }
    });

    test('3.1 i 3.3: surten totes les proves del banc, ben formades', () {
      final proves = <String>{}, falses = <String>{};
      for (final seed in seeds) {
        final c = GameContent.forSeed(seed);
        final p = c.puzzlesById['3.1']!;
        proves.add(p.title);
        final order = p.steps[0] as OrderStep;
        expect(order.lines.first, startsWith('Cas base'), reason: p.title);
        expect(order.lines.last, startsWith('Conclusió'), reason: p.title);
        expect(order.initialOrder, hasLength(order.lines.length));

        final f = c.puzzlesById['3.3']!;
        falses.add(f.title);
        final tap = f.steps[0] as TapLineStep;
        expect(tap.wrongLine, inInclusiveRange(0, tap.lines.length - 1));
        expect(f.statement, contains('«demostra»'));
      }
      expect(proves, hasLength(4));
      expect(falses, hasLength(3));
    });

    test('3.4: les bases compleixen les congruències', () {
      for (final seed in seeds) {
        final pz = GameContent.forSeed(seed).puzzlesById['3.4']!;
        final b11 = int.parse(
          RegExp(r'Ex\. 11: (\d+)').firstMatch(pz.statement)![1]!,
        );
        expect(b11 % 4, 1);
        final m = RegExp(
          r'Quant val (\d+)\S* = (\d+) mòdul 10',
        ).firstMatch((pz.steps[2] as CodeStep).prompt)!;
        final pow = int.parse(m[2]!);
        expect(pow % 10, 1, reason: '$seed');
        // pow és una potència de la base.
        var x = 1, base = int.parse(m[1]!);
        while (x < pow) {
          x *= base;
        }
        expect(x, pow, reason: '$seed');
      }
    });

    test('el pany és coherent a tot arreu', () {
      for (final seed in seeds) {
        final c = GameContent.forSeed(seed);
        final p = c.pany;
        final (d1, d2, d3) = p.digits;
        for (final d in [d1, d2, d3, p.a, p.c]) {
          expect(d, inInclusiveRange(1, 7), reason: '$seed');
        }
        expect(mod(p.k * p.a, 7), 1);
        expect(mod(p.m * p.c - p.t, 7), 0);
        expect([for (final r in c.rooms) r.digit], [d1, d2, d3]);
        // L'últim puzle obligatori de cada sala anuncia la seva xifra.
        for (final r in c.rooms) {
          final last = r.puzzles.lastWhere((x) => !x.optional);
          expect(last.outro, contains('un ${r.digit} '), reason: r.id);
        }
        final door = c.finalPuzzle;
        expect((door.steps[0] as CodeStep).solution, '${p.a}');
        expect((door.steps[1] as CodeStep).solution, '${p.c}');
        final lock = door.steps[2] as WheelLockStep;
        expect(lock.solution, ['${p.a}', '$d1', '${p.c}', '$d2', '$d3']);
        for (final r in c.rooms) {
          expect(lock.locked, contains(r.digitPosition - 1));
          expect(lock.solution![r.digitPosition - 1], '${r.digit}');
        }
        expect(
          c.secretBookText,
          contains("a és l'invers de ${p.k}; c·${p.m} ≡ ${p.t}, a ℤ₇"),
        );
        expect(c.intro, contains('«${p.pattern}»'));
        expect(c.homeBlurb, contains('«${p.pattern}»'));
        expect(door.statement, contains('«${p.pattern}»'));
      }
    });

    test('a cada llavor, cada pas accepta la seva solució', () {
      for (final seed in seeds) {
        final c = GameContent.forSeed(seed);
        for (final pz in c.puzzlesById.values) {
          expect(pz.hints, hasLength(3), reason: '${pz.id} · llavor $seed');
          for (final s in pz.steps) {
            expect(
              s.check(solutionOf(s)),
              isTrue,
              reason: '${pz.id} · llavor $seed',
            );
          }
        }
      }
    });
  });

  group('Sala 1 · Conjunts', () {
    test('1.1 Venn: |A∪B| = 36 i cap = 4', () {
      const total = 40, a = 25, b = 18, ab = 7;
      const union = a + b - ab;
      expect(union, 36);
      expect(total - union, 4);
      // Regions: només A, A∩B, només B, fora.
      expect([a - ab, ab, b - ab, total - union], [18, 7, 11, 4]);
      expect(p('1.1').steps[0].check([18, 7, 11, 4]), isTrue);
      expect(p('1.1').steps[1].check('36'), isTrue);
    });

    test('1.2 De Morgan sobre un univers de prova', () {
      final u = {for (var i = 1; i <= 8; i++) i};
      final a = {1, 2, 3, 4}, b = {3, 4, 5, 6};
      Set<int> c(Set<int> x) => u.difference(x);
      expect(c(a.union(b)), c(a).intersection(c(b)));
      expect(c(a.intersection(b)), c(a).union(c(b)));
      expect(p('1.2').steps[0].solutionLabel, 'A′ ∩ B′');
      expect(p('1.2').steps[1].solutionLabel, 'A′ ∪ B′');
      // Els passos accepten la seva pròpia solució i expressions equivalents.
      expect(p('1.2').steps[0].check('A′ ∩ B′'), isTrue);
      expect(p('1.2').steps[0].check('(B′ ∩ A′)'), isTrue);
      expect(p('1.2').steps[1].check('B′ ∪ A′'), isTrue);
      expect(p('1.2').steps[0].check('A′ ∪ B′'), isFalse);
    });

    test('1.3 partició de {1..6} i classe [2] mod 3', () {
      final parts = [
        {1, 3, 5},
        {2, 4},
        {6},
      ];
      expect(parts.every((x) => x.isNotEmpty), isTrue);
      expect(parts.expand((x) => x).toList()..sort(), [1, 2, 3, 4, 5, 6]);
      final class2 = {
        for (var b = 1; b <= 6; b++)
          if (mod(b - 2, 3) == 0) b,
      };
      expect(class2, {2, 5});
      expect(p('1.3').steps[0].solutionLabel, '{1,3,5}, {2,4}, {6}');
      expect(p('1.3').steps[1].check(parts), isTrue);
      expect(
        p('1.3').steps[2].check([
          {3, 6},
          {1, 4},
          {2, 5},
        ]),
        isTrue,
      );
      expect(p('1.3').steps[2].check(parts), isFalse);
      // Les classes de la solució són exactament les classes mod 3.
      final classes = [
        for (var r = 0; r < 3; r++)
          {
            for (var x = 1; x <= 6; x++)
              if (mod(x, 3) == r) x,
          },
      ];
      expect(p('1.3').steps[2].check(classes), isTrue);
      expect(p('1.3').steps[3].solutionLabel, '{2, 5}');
    });
  });

  group('Sala 2 · Aritmètica modular', () {
    test('2.1 invers de 2 a ℤ₅, inversos a ℤ₆, 2x ≡ 1 (mod 6)', () {
      expect(inverse(2, 5), 3);
      expect(
        [
          for (var x = 1; x <= 6; x++)
            if (inverse(x, 6) != null) x,
        ],
        [1, 5],
      );
      expect(solveLinear(2, 1, 6), isEmpty);
      final s = p('2.1').steps;
      expect(s[2].check('3'), isTrue);
      expect(s[3].solutionLabel, '1 i 5');
      expect(s[3].check({1, 5}), isTrue);
      expect(s[3].check({1, 3, 5}), isFalse);
      expect(s[4].solutionLabel, 'No té solució');
      expect(s[4].check(WheelLockStep.noSolution), isTrue);
      expect(s[4].check(['3']), isFalse);
    });

    test('2.1 taula mod 5: caselles pre-emplenades del PDF', () {
      int cell(int r, int c) => toProfNotation(r * c, 5);
      expect(cell(1, 2), 2);
      expect([cell(2, 1), cell(2, 3), cell(2, 4), cell(2, 5)], [2, 1, 3, 5]);
      expect(cell(3, 4), 2);
      expect([cell(4, 1), cell(4, 3), cell(4, 4)], [4, 2, 1]);

      // El TableStep pre-emplena exactament aquestes caselles.
      final table = p('2.1').steps[0] as TableStep;
      final pairs = [for (final i in table.prefilled) (i ~/ 5 + 1, i % 5 + 1)];
      expect(pairs, [
        (1, 2),
        (2, 1),
        (2, 3),
        (2, 4),
        (2, 5),
        (3, 4),
        (4, 1),
        (4, 3),
        (4, 4),
      ]);
      for (final (r, c) in pairs) {
        expect(table.cell(r - 1, c - 1), cell(r, c));
      }
      expect(table.check(table.solution), isTrue);

      // Les caselles amb 1 són les parelles d'inversos de ℤ₅.
      final ones = p('2.1').steps[1] as TableStep;
      expect(
        {for (final i in ones.markedCells) (i ~/ 5 + 1, i % 5 + 1)},
        {(1, 1), (2, 3), (3, 2), (4, 4)},
      );
    });

    test('2.2 codi 4x1y → 4213 i vocal X = i', () {
      const a = 4, c = 1;
      final bs = solveLinear(3, c, 5);
      expect(bs, [2]);
      final d = mod(2 * a, 5);
      expect('$a${bs.single}$c$d', '4213');
      expect(p('2.2').steps[0].check(['4', '2', '1', '3']), isTrue);
      expect(p('2.2').steps[0].solutionLabel.replaceAll(' ', ''), '4213');

      final xs = solveLinear(3, 1, 5);
      expect(xs, [2]); // única
      expect('aeiou'[xs.single], 'i');
      expect(p('2.2').steps[1].check(['e', 'o', 'i', 'i']), isTrue);
      // Única: cap altra vocal obre el pany.
      for (final v in ['a', 'e', 'o', 'u']) {
        expect(p('2.2').steps[1].check(['e', 'o', 'i', v]), isFalse);
      }
    });

    test('2.3 César x+3: ERP_GLD → BON DIA', () {
      expect(affineEncrypt('BON DIA', 1, 3), 'ERP GLD');
      expect(affineDecrypt('ERP GLD', 1, 3), 'BON DIA');
      expect(p('2.3').steps[0].check('bon dia'), isTrue);
      expect(p('2.3').steps[0].check('BON_DIA'), isTrue);
    });

    test('2.3 2x+1 (mod 6): cada lletra de BDF té 2 orígens', () {
      for (final y in [1, 3, 5]) {
        expect(solveLinear(2, y - 1, 6), hasLength(2));
      }
      expect(p('2.3').steps[1].solutionLabel, contains('2 orígens'));
    });

    test('2.3 afí 2x+3 (mod 27): YSFMG → LIBRO', () {
      expect(alphabet27, hasLength(27));
      expect(alphabet27.indexOf('Ç'), 14);
      expect(inverse(2, 27), 14);
      expect(affineEncrypt('LIBRO', 2, 3), 'YSFMG');
      expect(affineDecrypt('YSFMG', 2, 3), 'LIBRO');
      expect(p('2.3').steps[2].check('libro'), isTrue);
    });

    test('Ex. 5 · g(x) = 2x a ℤ₇', () {
      int g(int x) => mod(2 * x, 7);
      int gInv(int y) => mod(inverse(2, 7)! * y, 7);
      expect([g(3), g(5), gInv(4), gInv(2)], [6, 3, 2, 1]);
      expect({for (var x = 0; x < 7; x++) g(x)}, hasLength(7)); // bijectiva
    });
  });

  group('Sala 3 · Inducció', () {
    test('3.1 Bernoulli es compleix per a valors de prova', () {
      for (final a in [-1.0, -0.5, 0.0, 0.3, 2.0, 5.0]) {
        var pow = 1.0;
        for (var n = 0; n <= 10; n++) {
          expect(pow >= 1 + a * n - 1e-9, isTrue, reason: 'a=$a n=$n');
          pow *= 1 + a;
        }
      }
      final s = p('3.1').steps;
      final order = s[0] as OrderStep;
      expect(order.lines, hasLength(6));
      expect(order.lines.first, contains('(1+a)⁰ = 1 = 1 + a·0'));
      expect(order.lines.last, startsWith('Conclusió'));
      expect(order.check([0, 1, 2, 3, 4, 5]), isTrue);
      expect(order.check(order.initialOrder), isFalse);
      // L'ordre inicial és una permutació de totes les línies.
      expect(order.initialOrder.toSet(), {0, 1, 2, 3, 4, 5});
      expect(order.celebration, Celebration.dominoes);
      expect(s[1].solutionLabel, 'Perquè a ≥ −1 ⇒ 1 + a ≥ 0');
      expect(s[2].solutionLabel, 'Perquè a² ≥ 0 i k ≥ 0');
    });

    test('3.2 Hanoi: M(n) = 2M(n−1)+1 = 2ⁿ − 1', () {
      var m = 0;
      for (var n = 1; n <= 10; n++) {
        m = 2 * m + 1;
        expect(m, (1 << n) - 1);
        if (n == 3) expect(m, 7);
        if (n == 5) expect(m, 31);
      }
      final s = p('3.2').steps;
      expect((s[0] as HanoiStep).minMoves, 7);
      expect((s[1] as HanoiStep).minMoves, 15);
      expect(s[0].check(hanoiSolution(3)), isTrue);
      expect(s[1].check(hanoiSolution(4)), isTrue);
      expect(s[2].check('31'), isTrue);
      expect(s[3].solutionLabel, 'M(n) = 2ⁿ − 1');
    });

    test('3.3 cavalls: falla el pas de k=1 a 2', () {
      // Amb k+1 = 2, els k primers {c₁} i els k últims {c₂} són disjunts.
      expect({1}.intersection({2}), isEmpty);
      final tap = p('3.3').steps[0] as TapLineStep;
      expect(tap.lines[tap.wrongLine], contains('comparteixen'));
      expect(tap.celebration, Celebration.disjointHorses);
      expect(p('3.3').steps[1].solutionLabel, 'Al pas de k = 1 a k + 1 = 2');
    });

    test('3.4 bonus: 5ⁿ+1 parell però no múltiple de 4; 10 | 3⁴ⁿ+9', () {
      var five = BigInt.one, three4n = BigInt.one;
      for (var n = 0; n <= 30; n++) {
        final a = five + BigInt.one;
        expect(a % BigInt.two, BigInt.zero, reason: 'n=$n');
        expect(a % BigInt.from(4), BigInt.two, reason: 'n=$n');
        expect((three4n + BigInt.from(9)) % BigInt.from(10), BigInt.zero);
        five *= BigInt.from(5);
        three4n *= BigInt.from(81);
      }
      expect(mod(5, 4), 1);
      expect(mod(81, 10), 1);
      final pz = p('3.4');
      expect(pz.optional, isTrue);
      expect(pz.bonus, 60);
      expect(pz.steps.map((s) => s.solutionLabel).take(3), ['1', '2', '1']);
    });

    test('3.4 és opcional: la sala se supera sense ell', () {
      final room = rooms.firstWhere((r) => r.id == 'sala3');
      expect(room.puzzles.where((pz) => !pz.optional), hasLength(3));
      expect(room.puzzles.last.optional, isTrue);
    });
  });

  group("Porta d'Euler (Ex. 4)", () {
    test('a = 3⁻¹ = 5, 5c ≡ 4 → c = 5, codi 53554', () {
      final a = inverse(3, 7)!;
      final cs = solveLinear(5, 4, 7);
      expect(a, 5);
      expect(cs, [5]);
      final code = '${toProfNotation(a, 7)}3${toProfNotation(cs.single, 7)}54';
      expect(code, '53554');
      expect(secretBookText, contains("a és l'invers de 3; c·5 ≡ 4, a ℤ₇"));
      expect(secretBookUnlockedBy, '2.3');
      expect(finalPuzzle.steps[0].check('5'), isTrue);
      expect(finalPuzzle.steps[1].check('5'), isTrue);
      final lock = finalPuzzle.steps[2] as WheelLockStep;
      expect(lock.solution!.join(), '53554');
      expect(lock.check(code.split('')), isTrue);
      // Rodes de 1 a 7 (notació del PDF), amb les posicions 2, 4 i 5 fixes.
      expect(lock.symbols, ['1', '2', '3', '4', '5', '6', '7']);
      expect(lock.locked, [1, 3, 4]);
      // Les rodes fixes són les xifres que donen les sales.
      for (final r in rooms) {
        expect(lock.solution![r.digitPosition - 1], '${r.digit}');
        expect(lock.locked, contains(r.digitPosition - 1));
      }
    });
  });
}
