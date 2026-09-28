// Contrast mínim AA (WCAG 2.1): 4,5 per a text normal, 3 per a elements
// gràfics i text gran.
import 'helpers.dart';
import 'package:cambra_euler/core/theme.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Color resultant de posar [fg] amb opacitat sobre [bg].
Color over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

void main() {
  test(
    'contrastRatio: blanc sobre negre és 21 i un color amb si mateix, 1',
    () {
      expect(
        contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
        closeTo(21, 0.01),
      );
      expect(contrastRatio(AppColors.gold, AppColors.gold), closeTo(1, 0.001));
    },
  );

  test('text principal sobre els fons del tema', () {
    for (final bg in [AppColors.ink, AppColors.slate, AppColors.card]) {
      expect(contrastRatio(AppColors.chalk, bg), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(AppColors.gold, bg), greaterThanOrEqualTo(4.5));
    }
  });

  test('botons daurats: text ink sobre gold', () {
    expect(
      contrastRatio(AppColors.ink, AppColors.gold),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('missatges d\'error i d\'encert', () {
    for (final bg in [AppColors.ink, AppColors.card]) {
      expect(contrastRatio(AppColors.error, bg), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(AppColors.ok, bg), greaterThanOrEqualTo(4.5));
    }
  });

  test('text secundari (chalk al 70 %)', () {
    for (final bg in [AppColors.ink, AppColors.card]) {
      final c = over(AppColors.chalk.withValues(alpha: 0.7), bg);
      expect(contrastRatio(c, bg), greaterThanOrEqualTo(4.5));
    }
  });

  for (final r in rooms) {
    test('colors de ${r.name}', () {
      final bar = accessibleBar(r.color);
      expect(contrastRatio(onColor(bar), bar), greaterThanOrEqualTo(4.5));
      expect(
        contrastRatio(readableOn(r.color), AppColors.ink),
        greaterThanOrEqualTo(4.5),
      );
      final icon = readableOn(r.color, background: AppColors.card, minRatio: 3);
      expect(contrastRatio(icon, AppColors.card), greaterThanOrEqualTo(3));
    });
  }

  test('accessibleBar no toca els colors que ja passen', () {
    expect(accessibleBar(AppColors.clocks), AppColors.clocks);
    expect(accessibleBar(AppColors.domino), AppColors.domino);
  });
}
