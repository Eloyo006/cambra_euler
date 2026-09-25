import 'package:cambra_euler/core/modular.dart';
import 'package:cambra_euler/core/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mod sempre dona un representant a {0..n-1}', () {
    expect(mod(7, 5), 2);
    expect(mod(-1, 5), 4);
    expect(mod(-10, 5), 0);
  });

  test('inverse', () {
    expect(inverse(3, 7), 5);
    expect(inverse(2, 6), isNull);
    expect(inverse(1, 2), 1);
  });

  test('solveLinear', () {
    expect(solveLinear(2, 2, 6), [1, 4]);
    expect(solveLinear(5, 4, 7), [5]);
  });

  test('toProfNotation fa servir {1..n}', () {
    expect(toProfNotation(0, 7), 7);
    expect(toProfNotation(14, 7), 7);
    expect(toProfNotation(15, 7), 1);
  });

  test('afí: xifrar i desxifrar són inverses', () {
    const msg = 'ÇA I LA';
    expect(affineDecrypt(affineEncrypt(msg, 5, 7), 5, 7), msg);
    expect(() => affineDecrypt('A', 3, 0), throwsArgumentError);
  });

  test('formatTime', () {
    expect(formatTime(0), '00:00');
    expect(formatTime(75), '01:15');
    expect(formatTime(3725), '1:02:05');
  });
}
