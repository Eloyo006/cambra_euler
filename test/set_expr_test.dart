import 'package:cambra_euler/core/set_expr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evalSetExpr (U = {1..8}, A = {1..4}, B = {3..6})', () {
    test('variables i operacions', () {
      expect(evalSetExpr('A'), {1, 2, 3, 4});
      expect(evalSetExpr('A ∪ B'), {1, 2, 3, 4, 5, 6});
      expect(evalSetExpr('A ∩ B'), {3, 4});
      expect(evalSetExpr('A′'), {5, 6, 7, 8});
      expect(evalSetExpr("A''"), {1, 2, 3, 4});
    });

    test('complementari de parèntesis', () {
      expect(evalSetExpr('(A ∪ B)′'), {7, 8});
      expect(evalSetExpr('(A ∩ B)′'), {1, 2, 5, 6, 7, 8});
    });

    test('∩ té més prioritat que ∪', () {
      // A ∪ (B ∩ A′) = A ∪ {5,6}
      expect(evalSetExpr('A ∪ B ∩ A′'), {1, 2, 3, 4, 5, 6});
      expect(evalSetExpr('(A ∪ B) ∩ A′'), {5, 6});
    });

    test('errors de sintaxi', () {
      for (final bad in [
        '',
        'A ∪',
        '(A',
        'A)',
        'A B',
        '∩ A',
        'C',
        'A + B',
        '()',
      ]) {
        expect(
          () => evalSetExpr(bad),
          throwsA(isA<SetExprError>()),
          reason: bad,
        );
      }
    });
  });

  group('setExprEquivalent', () {
    test('lleis de De Morgan', () {
      expect(setExprEquivalent('(A∪B)′', 'A′∩B′'), isTrue);
      expect(setExprEquivalent('(A∩B)′', 'A′∪B′'), isTrue);
    });

    test('altres equivalències i no-equivalències', () {
      expect(setExprEquivalent('A ∩ (A ∪ B)', 'A'), isTrue); // absorció
      expect(setExprEquivalent('(A∪B)′', 'A′∪B′'), isFalse);
      expect(setExprEquivalent('A ∩ B', 'B ∩ A'), isTrue);
    });

    test('una expressió mal formada no és equivalent a res', () {
      expect(setExprEquivalent('A ∩', 'A'), isFalse);
    });
  });
}
