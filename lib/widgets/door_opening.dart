import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Dues fulles de porta que s'obren i deixen veure [child].
class DoorOpening extends StatefulWidget {
  const DoorOpening({super.key, required this.child, this.play = true});

  final Widget child;

  /// Si és fals, es mostra directament [child] (p. ex. en tornar-hi).
  final bool play;

  @override
  State<DoorOpening> createState() => _DoorOpeningState();
}

class _DoorOpeningState extends State<DoorOpening>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
    value: widget.play ? 0 : 1,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          if (_c.isCompleted) return const SizedBox.shrink();
          // El pany gira primer; després s'obren les fulles.
          final unlock = Curves.easeInOut.transform(
            (_c.value / 0.35).clamp(0, 1),
          );
          final open = Curves.easeInCubic.transform(
            ((_c.value - 0.35) / 0.65).clamp(0, 1),
          );
          return IgnorePointer(
            child: LayoutBuilder(
              builder: (context, box) {
                final half = box.maxWidth / 2;
                return Stack(
                  children: [
                    Positioned(
                      left: -half * open,
                      top: 0,
                      bottom: 0,
                      width: half,
                      child: const _Leaf(alignRight: true),
                    ),
                    Positioned(
                      right: -half * open,
                      top: 0,
                      bottom: 0,
                      width: half,
                      child: const _Leaf(alignRight: false),
                    ),
                    Center(
                      child: Opacity(
                        opacity: 1 - open,
                        child: Transform.rotate(
                          angle: unlock * 3.1416,
                          child: Icon(
                            unlock < 1 ? Icons.lock : Icons.lock_open,
                            size: 64,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    ],
  );
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.alignRight});
  final bool alignRight;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.slate,
      border: Border(
        left: alignRight
            ? BorderSide.none
            : const BorderSide(color: AppColors.gold, width: 2),
        right: alignRight
            ? const BorderSide(color: AppColors.gold, width: 2)
            : BorderSide.none,
      ),
    ),
    child: Center(
      child: Container(
        width: 80,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
      ),
    ),
  );
}
