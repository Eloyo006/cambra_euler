import 'dart:ui';

import 'package:cambra_euler/core/venn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = VennLayout(Size(300, 300 * VennLayout.aspect));

  test('els centres dels cercles cauen a la regió correcta', () {
    expect(
      layout.regionAt(layout.centerA - Offset(layout.radius * 0.6, 0)),
      VennLayout.onlyA,
    );
    expect(
      layout.regionAt(layout.centerB + Offset(layout.radius * 0.6, 0)),
      VennLayout.onlyB,
    );
    expect(
      layout.regionAt(Offset(layout.size.width / 2, layout.size.height / 2)),
      VennLayout.both,
    );
    expect(layout.regionAt(const Offset(5, 5)), VennLayout.outside);
  });

  test('fora del rectangle no hi ha cap regió', () {
    expect(layout.regionAt(const Offset(-1, 10)), isNull);
    expect(layout.regionAt(Offset(10, layout.size.height + 1)), isNull);
  });

  test('cada etiqueta és dins de la seva regió', () {
    for (var r = 0; r < 4; r++) {
      expect(layout.regionAt(layout.labelPosition(r)), r, reason: 'regió $r');
    }
  });

  test('els cercles se superposen però no del tot', () {
    final d = (layout.centerA - layout.centerB).distance;
    expect(d, lessThan(2 * layout.radius));
    expect(d, greaterThan(layout.radius * 0.5));
  });
}
