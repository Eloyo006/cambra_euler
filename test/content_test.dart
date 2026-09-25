// Verifica matemàticament totes les solucions de la §4 del brief.
import 'package:cambra_euler/core/modular.dart';
import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/models/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

Puzzle p(String id) => puzzlesById[id]!;

void main() {
  group('Estructura', () {
    test('3 sales de 3 puzles, 3 pistes cadascun', () {
      expect(rooms, hasLength(3));
      for (final r in rooms) {
        expect(r.puzzles, hasLength(3));
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
        for (final s in pz.steps.where((s) => s.kind == StepKind.choice)) {
          expect(s.correctIndex, inInclusiveRange(0, s.options.length - 1));
          expect(s.options.toSet(), hasLength(s.options.length));
        }
      }
    });

    test('el pany: sales → 3 (pos 2), 5 (pos 4), 4 (pos 5)', () {
      expect([for (final r in rooms) (r.digit, r.digitPosition)],
          [(3, 2), (5, 4), (4, 5)]);
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
      expect(p('1.1').steps[0].check('36'), isTrue);
      expect(p('1.1').steps[1].check('4'), isTrue);
    });

    test('1.2 De Morgan sobre un univers de prova', () {
      final u = {for (var i = 1; i <= 8; i++) i};
      final a = {1, 2, 3, 4}, b = {3, 4, 5, 6};
      Set<int> c(Set<int> x) => u.difference(x);
      expect(c(a.union(b)), c(a).intersection(c(b)));
      expect(c(a.intersection(b)), c(a).union(c(b)));
      expect(p('1.2').steps[0].solutionLabel, 'A′ ∩ B′');
      expect(p('1.2').steps[1].solutionLabel, 'A′ ∪ B′');
    });

    test('1.3 partició de {1..6} i classe [2] mod 3', () {
      final parts = [
        {1, 3, 5},
        {2, 4},
        {6},
      ];
      expect(parts.every((x) => x.isNotEmpty), isTrue);
      expect(parts.expand((x) => x).toList()..sort(), [1, 2, 3, 4, 5, 6]);
      final class2 = {for (var b = 1; b <= 6; b++) if (mod(b - 2, 3) == 0) b};
      expect(class2, {2, 5});
      expect(p('1.3').steps[0].solutionLabel, '{1,3,5}, {2,4}, {6}');
      expect(p('1.3').steps[1].solutionLabel, '{2, 5}');
    });
  });

  group('Sala 2 · Aritmètica modular', () {
    test('2.1 invers de 2 a ℤ₅, inversos a ℤ₆, 2x ≡ 1 (mod 6)', () {
      expect(inverse(2, 5), 3);
      expect([for (var x = 1; x <= 6; x++) if (inverse(x, 6) != null) x], [1, 5]);
      expect(solveLinear(2, 1, 6), isEmpty);
      expect(p('2.1').steps[0].check('3'), isTrue);
      expect(p('2.1').steps[1].solutionLabel, '1 i 5');
      expect(p('2.1').steps[2].solutionLabel, 'No té solució');
    });

    test('2.1 taula mod 5: caselles pre-emplenades del PDF', () {
      int cell(int r, int c) => toProfNotation(r * c, 5);
      expect(cell(1, 2), 2);
      expect([cell(2, 1), cell(2, 3), cell(2, 4), cell(2, 5)], [2, 1, 3, 5]);
      expect(cell(3, 4), 2);
      expect([cell(4, 1), cell(4, 3), cell(4, 4)], [4, 2, 1]);
    });

    test('2.2 codi 4x1y → 4213 i vocal X = i', () {
      const a = 4, c = 1;
      final bs = solveLinear(3, c, 5);
      expect(bs, [2]);
      final d = mod(2 * a, 5);
      expect('$a${bs.single}$c$d', '4213');
      expect(p('2.2').steps[0].check('4213'), isTrue);
      expect(p('2.2').steps[0].check('4 2 1 3'), isTrue);

      final xs = solveLinear(3, 1, 5);
      expect(xs, [2]); // única
      expect('aeiou'[xs.single], 'i');
      expect(p('2.2').steps[1].check('i'), isTrue);
      expect(p('2.2').steps[1].check('I'), isTrue);
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
      expect(s[0].solutionLabel, '(1+a)⁰ = 1 = 1 + a·0');
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
      expect(p('3.2').steps[0].check('7'), isTrue);
      expect(p('3.2').steps[1].check('31'), isTrue);
      expect(p('3.2').steps[2].solutionLabel, 'M(n) = 2ⁿ − 1');
    });

    test('3.3 cavalls: falla el pas de k=1 a 2', () {
      // Amb k+1 = 2, els k primers {c₁} i els k últims {c₂} són disjunts.
      expect({1}.intersection({2}), isEmpty);
      expect(p('3.3').steps[0].solutionLabel, 'Al pas de k = 1 a k + 1 = 2');
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
      expect(finalPuzzle.steps.map((s) => s.solutionLabel), ['5', '5', '53554']);
    });
  });
}
