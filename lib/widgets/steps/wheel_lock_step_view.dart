import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import '../../state/settings.dart';
import 'step_view.dart';

/// Pany de rodes fet amb [ListWheelScrollView]. Les rodes bloquejades venen
/// fixades. Opcionalment hi ha un botó «No té solució».
class WheelLockStepView extends StatefulWidget {
  const WheelLockStepView({
    super.key,
    required this.step,
    required this.onSubmit,
  });

  final WheelLockStep step;
  final SubmitAnswer onSubmit;

  @override
  State<WheelLockStepView> createState() => _WheelLockStepViewState();
}

class _WheelLockStepViewState extends State<WheelLockStepView> {
  late final List<FixedExtentScrollController> _controllers = [
    for (var i = 0; i < widget.step.wheels; i++)
      FixedExtentScrollController(initialItem: _initialIndex(i)),
  ];

  int _initialIndex(int wheel) {
    final s = widget.step.solution;
    if (s != null && widget.step.locked.contains(wheel)) {
      return widget.step.symbols.indexOf(s[wheel]);
    }
    return 0;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _symbolAt(int wheel) {
    final n = widget.step.symbols.length;
    return widget.step.symbols[_controllers[wheel].selectedItem % n];
  }

  void _turn(int wheel, int delta) {
    final c = _controllers[wheel];
    c.animateToItem(
      c.selectedItem + delta,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            for (var w = 0; w < step.wheels; w++)
              _Wheel(
                controller: _controllers[w],
                symbols: step.symbols,
                locked: step.locked.contains(w),
                position: w + 1,
                onTurn: (d) => _turn(w, d),
                onChanged: () => setState(() {}),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => widget.onSubmit([
            for (var w = 0; w < step.wheels; w++) _symbolAt(w),
          ]),
          child: const Text('Obre el pany'),
        ),
        if (step.offerNoSolution) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(alignment: Alignment.center),
            onPressed: () => widget.onSubmit(WheelLockStep.noSolution),
            child: const Text('No té solució'),
          ),
        ],
      ],
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.symbols,
    required this.locked,
    required this.position,
    required this.onTurn,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final List<String> symbols;
  final bool locked;
  final int position;
  final void Function(int delta) onTurn;
  final VoidCallback onChanged;

  static const double _itemExtent = 44;

  @override
  Widget build(BuildContext context) {
    final current = controller.hasClients
        ? symbols[controller.selectedItem % symbols.length]
        : symbols[controller.initialItem % symbols.length];
    return Semantics(
      label: 'Roda $position: $current${locked ? ', bloquejada' : ''}',
      child: SizedBox(
        width: 54,
        child: Column(
          children: [
            IconButton(
              tooltip: 'Puja la roda $position',
              onPressed: locked ? null : () => onTurn(-1),
              icon: const Icon(Icons.keyboard_arrow_up),
            ),
            Container(
              height: _itemExtent * 3,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: locked
                      ? AppColors.chalk.withValues(alpha: 0.3)
                      : AppColors.gold,
                ),
              ),
              child: Stack(
                children: [
                  // Franja central que marca el valor seleccionat.
                  Center(
                    child: Container(
                      height: _itemExtent,
                      color: AppColors.gold.withValues(alpha: 0.12),
                    ),
                  ),
                  ExcludeSemantics(
                    child: ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: _itemExtent,
                      diameterRatio: 1.4,
                      physics: locked
                          ? const NeverScrollableScrollPhysics()
                          : const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (_) {
                        HapticFeedback.selectionClick();
                        Sfx.click();
                        onChanged();
                      },
                      childDelegate: ListWheelChildLoopingListDelegate(
                        children: [
                          for (final s in symbols)
                            Center(
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: locked
                                      ? AppColors.chalk.withValues(alpha: 0.6)
                                      : AppColors.gold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            locked
                ? const SizedBox(height: 48, child: Icon(Icons.lock, size: 20))
                : IconButton(
                    tooltip: 'Baixa la roda $position',
                    onPressed: () => onTurn(1),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
          ],
        ),
      ),
    );
  }
}
