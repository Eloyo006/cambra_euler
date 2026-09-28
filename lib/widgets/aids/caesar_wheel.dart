import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/modular.dart';
import '../../core/theme.dart';
import '../../state/settings.dart';

/// Roda de César: el disc exterior (fix) és el text clar i el disc interior
/// (giratori) és el text xifrat amb desplaçament k: x → x + k (mod 27).
class CaesarWheel extends StatefulWidget {
  const CaesarWheel({super.key});

  @override
  State<CaesarWheel> createState() => _CaesarWheelState();
}

class _CaesarWheelState extends State<CaesarWheel> {
  static const int n = 27;
  static const double _slot = 2 * math.pi / n;

  int _shift = 0;

  /// Angle acumulat durant l'arrossegament (radians).
  double _dragAngle = 0;
  int _dragStartShift = 0;

  void _setShift(int k) {
    final next = mod(k, n);
    if (next != _shift) {
      HapticFeedback.selectionClick();
      Sfx.click();
    }
    setState(() => _shift = next);
  }

  double _angleOf(Offset p, Size size) {
    final c = size.center(Offset.zero);
    return math.atan2(p.dy - c.dy, p.dx - c.dx);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final side = math.min(box.maxWidth, 320.0);
            final size = Size.square(side);
            double? last;
            return GestureDetector(
              onPanStart: (d) {
                last = _angleOf(d.localPosition, size);
                _dragAngle = 0;
                _dragStartShift = _shift;
              },
              onPanUpdate: (d) {
                final a = _angleOf(d.localPosition, size);
                var delta = a - (last ?? a);
                // Evita el salt de −π a π.
                if (delta > math.pi) delta -= 2 * math.pi;
                if (delta < -math.pi) delta += 2 * math.pi;
                last = a;
                _dragAngle += delta;
                // Girar en sentit horari fa entrar lletres anteriors.
                _setShift(_dragStartShift - (_dragAngle / _slot).round());
              },
              child: ExcludeSemantics(
                child: CustomPaint(
                  size: size,
                  painter: _WheelPainter(
                    _shift,
                    DefaultTextStyle.of(context).style,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Gira el disc interior enrere',
              onPressed: () => _setShift(_shift - 1),
              icon: const Icon(Icons.rotate_left),
            ),
            Flexible(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  'Desplaçament: $_shift  ·  A → ${alphabet27[_shift]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Gira el disc interior endavant',
              onPressed: () => _setShift(_shift + 1),
              icon: const Icon(Icons.rotate_right),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lletra del disc interior a la posició [i] amb desplaçament [k].
String innerLetter(int i, int k) => alphabet27[mod(i + k, alphabet27.length)];

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.shift, this.base);
  final int shift;
  final TextStyle base;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    const n = 27;
    final slot = 2 * math.pi / n;

    canvas.drawCircle(c, r - 1, Paint()..color = AppColors.card);
    canvas.drawCircle(c, r * 0.72, Paint()..color = AppColors.ink);
    canvas.drawCircle(
      c,
      r * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.gold.withValues(alpha: 0.6),
    );
    canvas.drawCircle(c, r * 0.36, Paint()..color = AppColors.card);

    // Marca a dalt: la parella que s'està llegint.
    final marker = Path()
      ..moveTo(c.dx, c.dy - r * 0.36)
      ..lineTo(c.dx - r * 0.07, c.dy - r * 0.99)
      ..lineTo(c.dx + r * 0.07, c.dy - r * 0.99)
      ..close();
    canvas.drawPath(
      marker,
      Paint()..color = AppColors.gold.withValues(alpha: 0.18),
    );

    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * slot;
      final dir = Offset(math.cos(angle), math.sin(angle));
      _letter(canvas, alphabet27[i], c + dir * (r * 0.86), AppColors.chalk, 15);
      _letter(
        canvas,
        innerLetter(i, shift),
        c + dir * (r * 0.56),
        AppColors.gold,
        14,
      );
    }
    _letter(canvas, 'clar', c + Offset(0, -r * 0.1), AppColors.chalk, 11);
    _letter(canvas, 'xifrat', c + Offset(0, r * 0.1), AppColors.gold, 11);
  }

  void _letter(Canvas canvas, String s, Offset at, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: base.copyWith(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.shift != shift;
}
