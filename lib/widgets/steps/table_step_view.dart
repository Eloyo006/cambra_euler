import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Taula de multiplicar de ℤₙ (notació {1, …, n}). Tres modes:
/// omplir les caselles buides amb un teclat 1…n, marcar les caselles que
/// valen un nombre, o tocar els elements (capçaleres) que tenen invers.
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
      widget.step.mode != TableMode.fill || widget.step.prefilled.contains(i)
          ? widget.step.solution[i]
          : null,
  ];

  /// Casella seleccionada (fill) o caselles/elements marcats (altres modes).
  int? _selected;
  final Set<int> _marked = {};

  TableMode get _mode => widget.step.mode;
  bool _isFixed(int i) =>
      _mode != TableMode.fill || widget.step.prefilled.contains(i);

  void _submit() {
    switch (_mode) {
      case TableMode.fill:
        if (_values.contains(null)) {
          widget.onReject('Omple totes les caselles.');
          return;
        }
        widget.onSubmit(_values.cast<int>().toList());
      case TableMode.markCells:
      case TableMode.pickInvertible:
        if (_marked.isEmpty) {
          widget.onReject(
            _mode == TableMode.markCells
                ? 'Toca les caselles que vols marcar.'
                : 'Toca els elements que tenen invers.',
          );
          return;
        }
        widget.onSubmit(Set<int>.of(_marked));
    }
  }

  void _toggle(int key) => setState(() {
    if (!_marked.remove(key)) _marked.add(key);
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final size = (box.maxWidth / (n + 1)).clamp(0.0, 64.0);
            Widget sized(Widget w) =>
                SizedBox(width: size, height: size, child: w);
            const header = TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            );
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    sized(const Center(child: Text('·', style: header))),
                    for (var c = 0; c < n; c++)
                      sized(Center(child: Text('${c + 1}', style: header))),
                  ],
                ),
                for (var r = 0; r < n; r++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      sized(_rowHeader(r + 1, header)),
                      for (var c = 0; c < n; c++) sized(_cell(r * n + c)),
                    ],
                  ),
              ],
            );
          },
        ),
        if (_mode == TableMode.pickInvertible) ...[
          const SizedBox(height: 12),
          Text(
            'Elements amb invers:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var x = 1; x <= n; x++)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: _Tile(
                    text: '$x',
                    label: 'Element $x${_marked.contains(x) ? ', marcat' : ''}',
                    color: _marked.contains(x)
                        ? AppColors.gold.withValues(alpha: 0.35)
                        : AppColors.slate,
                    border: _marked.contains(x) ? AppColors.gold : null,
                    onTap: () => _toggle(x),
                  ),
                ),
            ],
          ),
        ],
        if (_mode == TableMode.fill) ...[
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
        ],
        const SizedBox(height: 12),
        FilledButton(onPressed: _submit, child: const Text('Comprova')),
      ],
    );
  }

  Widget _rowHeader(int element, TextStyle style) =>
      Center(child: Text('$element', style: style));

  Widget _cell(int i) {
    final r = i ~/ n + 1, c = i % n + 1;
    final v = _values[i];
    switch (_mode) {
      case TableMode.fill:
        final fixed = _isFixed(i);
        return _Tile(
          text: v?.toString() ?? '',
          label: '$r per $c: ${v ?? 'buida'}',
          color: fixed ? AppColors.ink : AppColors.slate,
          style: TextStyle(
            fontSize: 18,
            color: fixed
                ? AppColors.chalk.withValues(alpha: 0.7)
                : AppColors.gold,
          ),
          border: _selected == i ? AppColors.gold : null,
          onTap: fixed ? null : () => setState(() => _selected = i),
        );
      case TableMode.markCells:
        final on = _marked.contains(i);
        return _Tile(
          text: '$v',
          label: '$r per $c: $v${on ? ', marcada' : ''}',
          color: on ? AppColors.gold.withValues(alpha: 0.35) : AppColors.ink,
          border: on ? AppColors.gold : null,
          onTap: () => _toggle(i),
        );
      case TableMode.pickInvertible:
        return _Tile(text: '$v', label: '$r per $c: $v', color: AppColors.ink);
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.text,
    required this.label,
    required this.color,
    this.style = const TextStyle(fontSize: 18),
    this.border,
    this.onTap,
  });

  final String text;
  final String label;
  final Color color;
  final TextStyle style;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: onTap != null,
    label: label,
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            alignment: Alignment.center,
            decoration: border == null
                ? null
                : BoxDecoration(
                    border: Border.all(color: border!, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
            child: ExcludeSemantics(child: Text(text, style: style)),
          ),
        ),
      ),
    ),
  );
}
