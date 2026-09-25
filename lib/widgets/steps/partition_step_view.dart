import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Prestatgeria: els llibres s'arrosseguen del prestatge a les caixes.
/// També es pot tocar un llibre i després la caixa on el vols posar.
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
  /// Caixa de cada llibre; si no hi és, el llibre és al prestatge.
  final Map<int, int> _boxOf = {};
  int? _selected;

  static const int shelf = -1;

  List<int> _itemsIn(int box) => [
    for (final item in widget.step.items)
      if ((_boxOf[item] ?? shelf) == box) item,
  ];

  void _move(int item, int box) => setState(() {
    if (box == shelf) {
      _boxOf.remove(item);
    } else {
      _boxOf[item] = box;
    }
    _selected = null;
  });

  void _tapArea(int box) {
    final item = _selected;
    if (item != null) _move(item, box);
  }

  void _submit() {
    if (_itemsIn(shelf).isNotEmpty) {
      widget.onReject('Encara queden llibres al prestatge.');
      return;
    }
    final boxes = [
      for (var b = 0; b < widget.step.boxes; b++) _itemsIn(b).toSet(),
    ];
    if (boxes.any((b) => b.isEmpty)) {
      widget.onReject('Cap caixa pot quedar buida.');
      return;
    }
    widget.onSubmit(boxes);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _area(shelf, 'Prestatge'),
      for (var b = 0; b < widget.step.boxes; b++) _area(b, 'Caixa ${b + 1}'),
      const SizedBox(height: 8),
      FilledButton(onPressed: _submit, child: const Text('Comprova')),
    ],
  );

  Widget _area(int box, String label) {
    final items = _itemsIn(box);
    return DragTarget<int>(
      onAcceptWithDetails: (d) => _move(d.data, box),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return Semantics(
          container: true,
          button: _selected != null,
          label: '$label: ${items.isEmpty ? 'buida' : items.join(', ')}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _tapArea(box),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minHeight: 88),
              decoration: BoxDecoration(
                color: box == shelf ? AppColors.slate : AppColors.ink,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hovering || _selected != null
                      ? AppColors.gold
                      : AppColors.chalk.withValues(alpha: 0.25),
                  width: hovering ? 2.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.chalk.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final i in items) _book(i)],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _book(int item) {
    final book = _Book(number: item, selected: _selected == item);
    return Draggable<int>(
      data: item,
      feedback: Material(color: Colors.transparent, child: book),
      childWhenDragging: Opacity(opacity: 0.3, child: book),
      child: Semantics(
        container: true,
        button: true,
        selected: _selected == item,
        label: 'Llibre $item',
        child: GestureDetector(
          onTap: () =>
              setState(() => _selected = _selected == item ? null : item),
          child: book,
        ),
      ),
    );
  }
}

class _Book extends StatelessWidget {
  const _Book({required this.number, required this.selected});
  final int number;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 60,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.library,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: selected
            ? AppColors.gold
            : AppColors.chalk.withValues(alpha: 0.3),
        width: selected ? 3 : 1,
      ),
      boxShadow: const [BoxShadow(blurRadius: 3, offset: Offset(1, 2))],
    ),
    child: Text(
      '$number',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.chalk,
      ),
    ),
  );
}
