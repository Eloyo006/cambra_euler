import 'package:cambra_euler/core/typography.dart';
import 'package:flutter_test/flutter_test.dart';

/// Posa «_» on hi ha un espai que no parteix i «^» on hi ha un
/// [wordJoiner], per llegir-ho fàcil.
String show(String s) =>
    keepMathTogether(s).replaceAll(nbsp, '_').replaceAll(wordJoiner, '^');

void main() {
  test('no es parteix al voltant de + − · …', () {
    expect(show('1 + 2 + … + k'), '1_+_2_+_…_+_k');
    expect(show('k³ − k'), 'k³_−_k');
  });

  test('un parèntesi curt queda sencer', () {
    expect(show('(k + 1)(k + 2)/2'), '(k_+_1)^(k_+_2)/^2');
  });

  test('no es parteix davant d\'una relació, ni darrere si és curt', () {
    expect(show('per a tot n ≥ 0.'), 'per a tot n_≥_0.');
    expect(show('0³ − 0 = 0, que és'), '0³_−_0_=_0, que és');
    // Darrere d'una relació, amb un terme llarg, sí que es pot partir.
    expect(show('x = 3(q + k² + k)'), 'x_= 3(q_+_k²_+_k)');
    // «(k» és curt, però obre una expressió: s'hi pot partir.
    expect(show('a = (k + 1)(k/2 + 1).'), 'a_= (k_+_1)^(k/^2_+_1).');
  });

  test('la prosa no es toca', () {
    expect(
      show('Arrossega les línies fins que'),
      'Arrossega les línies fins que',
    );
    expect(show('Cas base (n = 0): hola'), 'Cas base (n_=_0): hola');
  });

  test('el text visible no canvia (només el tipus d\'espai)', () {
    const s = 'Sumem k + 1 als dos costats: 1 + … + (k + 1) = k(k + 1)/2';
    expect(
      keepMathTogether(s).replaceAll(nbsp, ' ').replaceAll(wordJoiner, ''),
      s,
    );
  });
}
