import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Graella n×n de ℤₙ amb caselles pre-emplenades i un teclat 1…n.
class TableStepView extends StatefulWidget {
  const TableStepView({
    super.key,
    required this.step,
    required this.onSubmit,
    required this.onReject,
  });

  final TableStep step;
  final SubmitAnswer onSubmit;
  final RejectAction onReject;

  @override
  State<TableStepView> createState() => _TableStepViewState();
}

class _TableStepViewState extends State<TableStepView> {
  late final int n = widget.step.modulus;
  late final List<int?> _values = [
    for (var i = 0; i < n * n; i++)
      widget.step.prefilled.contains(i)
          ? widget.step.cell(i ~/ n, i % n)
          : null,
  ];
  int? _selected;

  bool _isFixed(int i) => widget.step.prefilled.contains(i);

  void _submit() {
    if (_values.contains(null)) {
      widget.onReject('Omple totes les caselles.');
      return;
    }
    widget.onSubmit(_values.cast<int>().toList());
  }

  Widget _cell(
    String text, {
    Color? color,
    Color? border,
    VoidCallback? onTap,
    String? label,
  }) => Semantics(
    button: onTap != null,
    label: label,
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color ?? Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            alignment: Alignment.center,
            decoration: border == null
                ? null
                : BoxDecoration(
                    border: Border.all(color: border, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
            child: Text(text, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final size = box.maxWidth / (n + 1);
            Widget sized(Widget w) =>
                SizedBox(width: size, height: size, child: w);
            const header = TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            );
            return Column(
              children: [
                Row(
                  children: [
                    sized(const Center(child: Text('·', style: header))),
                    for (var c = 0; c < n; c++)
                      sized(Center(child: Text('${c + 1}', style: header))),
                  ],
                ),
                for (var r = 0; r < n; r++)
                  Row(
                    children: [
                      sized(Center(child: Text('${r + 1}', style: header))),
                      for (var c = 0; c < n; c++)
                        sized(_buildCell(r * n + c, r, c)),
                    ],
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var v = 1; v <= n; v++)
              SizedBox(
                width: 48,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                  ),
                  onPressed: _selected == null
                      ? null
                      : () => setState(() => _values[_selected!] = v),
                  child: Text('$v', style: const TextStyle(fontSize: 18)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _submit, child: const Text('Comprova')),
      ],
    );
  }

  Widget _buildCell(int i, int r, int c) {
    final fixed = _isFixed(i);
    final v = _values[i];
    return _cell(
      v?.toString() ?? '',
      label: '${r + 1} per ${c + 1}: ${v ?? 'buida'}',
      color: fixed ? AppColors.ink : AppColors.slate,
      border: _selected == i ? AppColors.gold : null,
      onTap: fixed ? null : () => setState(() => _selected = i),
    );
  }
}
