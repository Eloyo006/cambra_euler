import 'package:cambra_euler/core/rng.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> take(Rng r, int n, int max) => [
  for (var i = 0; i < n; i++) r.nextInt(max),
];

void main() {
  test("l'algorisme no canvia (les partides desades en depenen)", () {
    // Si aquest test falla, les partides desades canviarien de contingut.
    expect(take(Rng(0, '1.1'), 5, 1000), [735, 34, 125, 418, 33]);
    expect(take(Rng(123456, 'porta'), 5, 1000), [374, 186, 557, 572, 458]);
  });

  test('mateixa llavor i clau → mateixa seqüència', () {
    expect(take(Rng(42, '2.3'), 20, 100), take(Rng(42, '2.3'), 20, 100));
  });

  test('claus o llavors diferents → seqüències diferents', () {
    final base = take(Rng(42, '2.3'), 20, 1000);
    expect(take(Rng(42, '2.2'), 20, 1000), isNot(base));
    expect(take(Rng(43, '2.3'), 20, 1000), isNot(base));
  });

  test('nextInt queda dins del rang i els cobreix tots', () {
    final r = Rng(7, 'x');
    final seen = <int>{};
    for (var i = 0; i < 500; i++) {
      final v = r.nextInt(6);
      expect(v, inInclusiveRange(0, 5));
      seen.add(v);
    }
    expect(seen, {0, 1, 2, 3, 4, 5});
  });

  test('shuffled és una permutació i no toca la llista original', () {
    final items = [1, 2, 3, 4, 5, 6, 7, 8];
    final out = Rng(9, 'y').shuffled(items);
    expect(out..sort(), items);
    expect(items, [1, 2, 3, 4, 5, 6, 7, 8]);
  });

  test('Rng.first tria sempre el primer i no barreja (variant del PDF)', () {
    final r = Rng.first();
    expect(r.pick(['pdf', 'b', 'c']), 'pdf');
    expect(r.pick([1, 2, 3]), 1);
    expect(r.shuffled([1, 2, 3, 4]), [1, 2, 3, 4]);
  });

  test('pick torna un element de la llista', () {
    final r = Rng(1, 'z');
    for (var i = 0; i < 50; i++) {
      expect(['a', 'b', 'c'], contains(r.pick(['a', 'b', 'c'])));
    }
  });
}
