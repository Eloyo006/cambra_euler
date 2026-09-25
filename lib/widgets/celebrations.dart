import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Una fila de dòminos que cauen un rere l'altre (inducció!).
class DominoFall extends StatefulWidget {
  const DominoFall({super.key, this.count = 9});
  final int count;

  @override
  State<DominoFall> createState() => _DominoFallState();
}

class _DominoFallState extends State<DominoFall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300 + 160 * widget.count),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Una fila de dòminos que cauen un rere l\'altre',
    child: SizedBox(
      height: 64,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [for (var i = 0; i < widget.count; i++) _domino(i)],
        ),
      ),
    ),
  );

  Widget _domino(int i) {
    final n = widget.count;
    // Cada fitxa comença a caure quan l'anterior ja és a mig camí.
    final start = i / (n + 1);
    final end = math.min(1.0, start + 2 / (n + 1));
    final t = Curves.easeIn.transform(
      ((_c.value - start) / (end - start)).clamp(0.0, 1.0),
    );
    return Transform.rotate(
      angle: t * 1.2,
      alignment: Alignment.bottomRight,
      child: Container(
        width: 14,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.chalk,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppColors.domino, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pip(),
            Container(height: 2, color: AppColors.domino),
            _pip(),
          ],
        ),
      ),
    );
  }

  Widget _pip() => Container(
    width: 4,
    height: 4,
    decoration: const BoxDecoration(
      color: AppColors.ink,
      shape: BoxShape.circle,
    ),
  );
}

/// El pas k = 1 → 2 dels cavalls: els grups {c₁} i {c₂} no es toquen.
class HorsesDisjoint extends StatefulWidget {
  const HorsesDisjoint({super.key, this.animate = true});
  final bool animate;

  @override
  State<HorsesDisjoint> createState() => _HorsesDisjointState();
}

class _HorsesDisjointState extends State<HorsesDisjoint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
    value: widget.animate ? 0 : 1,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label:
          'Amb dos cavalls, el grup dels k primers és {c₁} i el dels k '
          'últims és {c₂}. La intersecció és buida.',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            double phase(double a, double b) => Curves.easeOut.transform(
              ((_c.value - a) / (b - a)).clamp(0, 1),
            );
            final first = phase(0.0, 0.35);
            final last = phase(0.35, 0.7);
            final result = phase(0.7, 1.0);
            return Column(
              children: [
                Text('k + 1 = 2', style: text.titleSmall),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _group('k primers', '{c₁}', AppColors.library, first),
                    const SizedBox(width: 16),
                    _group('k últims', '{c₂}', AppColors.gold, last),
                  ],
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: result,
                  child: Text(
                    '{c₁} ∩ {c₂} = ∅ → no hi ha cap cavall que «enganxi» '
                    'els dos colors.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _group(String label, String set, Color color, double t) => Column(
    children: [
      Container(
        width: 96,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: color.withValues(alpha: t), width: 3),
          color: color.withValues(alpha: 0.12 * t),
        ),
        child: Icon(
          Icons.bedroom_baby_outlined,
          color: color == AppColors.gold
              ? AppColors.chalk
              : const Color(0xFF8D5A3B),
          size: 32,
        ),
      ),
      const SizedBox(height: 4),
      Opacity(
        opacity: t,
        child: SizedBox(
          width: 120,
          child: Text(
            '$label\n$set',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    ],
  );
}
