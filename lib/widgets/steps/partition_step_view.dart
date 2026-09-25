import 'package:flutter/material.dart';

import '../../models/puzzle.dart';
import 'step_view.dart';

/// Versió base: cada element tria caixa amb un selector. (El drag & drop
/// arriba a la Fase 3.)
class PartitionStepView extends StatefulWidget {
  const PartitionStepView({
    super.key,
    required this.step,
    required this.onSubmit,
    required this.onReject,
  });

  final PartitionStep step;
  final SubmitAnswer onSubmit;
  final RejectAction onReject;

  @override
  State<PartitionStepView> createState() => _PartitionStepViewState();
}

class _PartitionStepViewState extends State<PartitionStepView> {
  final Map<int, int> _boxOf = {};

  void _submit() {
    if (_boxOf.length < widget.step.items.length) {
      widget.onReject('Posa cada llibre en una caixa.');
      return;
    }
    widget.onSubmit([
      for (var b = 0; b < widget.step.boxes; b++)
        {
          for (final e in _boxOf.entries)
            if (e.value == b) e.key,
        },
    ]);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final item in widget.step.items)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(width: 72, child: Text('Llibre $item')),
              Expanded(
                child: SegmentedButton<int>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: [
                    for (var b = 0; b < widget.step.boxes; b++)
                      ButtonSegment(
                        value: b,
                        label: Text('${b + 1}'),
                        tooltip: 'Caixa ${b + 1}',
                      ),
                  ],
                  selected: {if (_boxOf[item] != null) _boxOf[item]!},
                  onSelectionChanged: (s) => setState(() {
                    if (s.isEmpty) {
                      _boxOf.remove(item);
                    } else {
                      _boxOf[item] = s.first;
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 4),
      FilledButton(onPressed: _submit, child: const Text('Comprova')),
    ],
  );
}
