import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../state/game_state.dart';

/// Rellotge de 60 posicions que mostra t mod 60 (t = temps total).
class ModClock extends ConsumerWidget {
  const ModClock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(gameProvider.select((s) => s.total));
    final r = total % 60;
    return Semantics(
      label: 'Temps total ${formatTime(total)}',
      child: Tooltip(
        message: 'Temps total: ${formatTime(total)}',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 32,
              child: CustomPaint(painter: _DialPainter(r)),
            ),
            const SizedBox(width: 8),
            Text(
              '≡ ${r.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter(this.value);
  final int value;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.chalk.withValues(alpha: 0.5),
    );
    final sweep = 2 * math.pi * value / 60;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius - 4),
      -math.pi / 2,
      sweep,
      true,
      Paint()..color = AppColors.gold.withValues(alpha: 0.35),
    );
    final angle = sweep - math.pi / 2;
    canvas.drawLine(
      c,
      c + Offset(math.cos(angle), math.sin(angle)) * (radius - 4),
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.value != value;
}
