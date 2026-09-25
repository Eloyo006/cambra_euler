import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Sacseja el fill horitzontalment quan es crida [ShakeState.shake].
class Shake extends StatefulWidget {
  const Shake({super.key, required this.child});
  final Widget child;

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void shake() => _c.forward(from: 0);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) {
      final t = _c.value;
      final dx = math.sin(t * math.pi * 6) * 12 * (1 - t);
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
  );
}

/// Check que apareix amb un rebot. Si [animate] és fals, es mostra estàtic.
class AnimatedCheck extends StatelessWidget {
  const AnimatedCheck({super.key, this.animate = true, this.size = 24});
  final bool animate;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.check_circle, color: AppColors.ok, size: size);
    if (!animate) return icon;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: icon,
    );
  }
}
