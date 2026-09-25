import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Versió base: rodes amb botons amunt/avall. Les bloquejades venen fixades.
/// (Les rodes amb ListWheelScrollView arriben a la Fase 4.)
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
  late final List<int> _index = [
    for (var i = 0; i < widget.step.solution.length; i++)
      widget.step.locked.contains(i)
          ? widget.step.symbols.indexOf(widget.step.solution[i])
          : 0,
  ];

  void _turn(int wheel, int delta) => setState(() {
    final n = widget.step.symbols.length;
    _index[wheel] = (_index[wheel] + delta) % n;
  });

  @override
  Widget build(BuildContext context) {
    final symbols = widget.step.symbols;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            for (var w = 0; w < _index.length; w++)
              _Wheel(
                symbol: symbols[_index[w]],
                locked: widget.step.locked.contains(w),
                position: w + 1,
                onUp: () => _turn(w, 1),
                onDown: () => _turn(w, -1),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () =>
              widget.onSubmit([for (final i in _index) symbols[i]]),
          child: const Text('Obre el pany'),
        ),
      ],
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.symbol,
    required this.locked,
    required this.position,
    required this.onUp,
    required this.onDown,
  });

  final String symbol;
  final bool locked;
  final int position;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Roda $position: $symbol${locked ? ', bloquejada' : ''}',
    child: SizedBox(
      width: 52,
      child: Column(
        children: [
          IconButton(
            onPressed: locked ? null : onUp,
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: locked
                    ? AppColors.chalk.withValues(alpha: 0.3)
                    : AppColors.gold,
              ),
            ),
            child: Text(
              symbol,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ),
          IconButton(
            onPressed: locked ? null : onDown,
            icon: Icon(locked ? Icons.lock : Icons.keyboard_arrow_down),
          ),
        ],
      ),
    ),
  );
}
