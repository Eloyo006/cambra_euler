import 'package:flutter/material.dart';

import '../../core/typography.dart';
import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Línies desordenades que cal arrossegar fins a l'ordre correcte.
class OrderStepView extends StatefulWidget {
  const OrderStepView({super.key, required this.step, required this.onSubmit});

  final OrderStep step;
  final SubmitAnswer onSubmit;

  @override
  State<OrderStepView> createState() => _OrderStepViewState();
}

class _OrderStepViewState extends State<OrderStepView> {
  late final List<int> _order = List.of(widget.step.initialOrder);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        onReorder: (from, to) => setState(() {
          if (to > from) to--;
          _order.insert(to, _order.removeAt(from));
        }),
        children: [
          for (var i = 0; i < _order.length; i++)
            Card(
              key: ValueKey(_order[i]),
              color: AppColors.ink,
              child: ReorderableDragStartListener(
                index: i,
                child: ListTile(
                  minTileHeight: 56,
                  leading: Text(
                    '${i + 1}',
                    style: const TextStyle(color: AppColors.gold),
                  ),
                  title: Text(keepMathTogether(widget.step.lines[_order[i]])),
                  trailing: const Icon(Icons.drag_handle),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () => widget.onSubmit(List<int>.of(_order)),
        child: const Text('Comprova'),
      ),
    ],
  );
}
