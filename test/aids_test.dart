import 'package:cambra_euler/core/modular.dart';
import 'package:cambra_euler/widgets/aids/caesar_wheel.dart';
import 'package:flutter_test/flutter_test.dart';

/// Llegeix la roda: busca la lletra xifrada al disc interior i retorna la
/// del disc exterior a la mateixa posició.
String readWheel(String cipher, int shift) => cipher.split('').map((y) {
  if (!alphabet27.contains(y)) return y;
  final i = List.generate(
    27,
    (i) => i,
  ).firstWhere((i) => innerLetter(i, shift) == y);
  return alphabet27[i];
}).join();

void main() {
  test('amb desplaçament 3, la B de fora queda sobre la E de dins', () {
    expect(innerLetter(1, 3), 'E');
    expect(innerLetter(26, 3), 'C'); // Z + 3 dona la volta
    expect(innerLetter(13, 1), 'Ç'); // N + 1 = Ç
  });

  test('llegint la roda amb k = 3, ERP_GLD diu BON DIA', () {
    expect(readWheel('ERP GLD', 3), 'BON DIA');
    expect(readWheel('ERP GLD', 3), affineDecrypt('ERP GLD', 1, 3));
  });

  test('amb un altre desplaçament no surt BON DIA', () {
    for (var k = 0; k < 27; k++) {
      if (k == 3) continue;
      expect(readWheel('ERP GLD', k), isNot('BON DIA'));
    }
  });
}
