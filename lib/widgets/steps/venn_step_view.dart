import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/venn.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Diagrama de Venn: es toca cada regió per escriure-hi un nombre.
/// Les regions correctes s'il·luminen de verd.
class VennStepView extends StatefulWidget {
  const VennStepView({
    super.key,
    required this.step,
    required this.onSubmit,
    required this.onReject,
  });

  final VennStep step;
  final SubmitAnswer onSubmit;
  final RejectAction onReject;

  @override
  State<VennStepView> createState() => _VennStepViewState();
}

class _VennStepViewState extends State<VennStepView> {
  late final List<int?> _values = List.filled(widget.step.regions.length, null);

  List<bool> get _correct => widget.step.correctRegions(_values);

  Future<void> _edit(int region) async {
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _NumberDialog(
        title: widget.step.labels[region],
        initial: _values[region],
      ),
    );
    if (value != null && mounted) setState(() => _values[region] = value);
  }

  void _submit() {
    if (_values.contains(null)) {
      widget.onReject('Escriu un nombre a cada regió.');
      return;
    }
    widget.onSubmit(_values.cast<int>().toList());
  }

  @override
  Widget build(BuildContext context) {
    final correct = _correct;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, box.maxWidth * VennLayout.aspect);
            final layout = VennLayout(size);
            return GestureDetector(
              onTapUp: (d) {
                final region = layout.regionAt(d.localPosition);
                if (region != null) _edit(region);
              },
              child: ExcludeSemantics(
                child: CustomPaint(
                  size: size,
                  painter: _VennPainter(layout, _values, correct),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Botons equivalents per a qui no pot tocar el diagrama.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _values.length; i++)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.center,
                  side: BorderSide(
                    color: correct[i]
                        ? AppColors.ok
                        : AppColors.chalk.withValues(alpha: 0.35),
                    width: correct[i] ? 2 : 1,
                  ),
                ),
                onPressed: () => _edit(i),
                child: Text('${widget.step.labels[i]}: ${_values[i] ?? '?'}'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _submit, child: const Text('Comprova')),
      ],
    );
  }
}

class _VennPainter extends CustomPainter {
  _VennPainter(this.layout, this.values, this.correct);

  final VennLayout layout;
  final List<int?> values;
  final List<bool> correct;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = AppColors.ink,
    );
    for (var i = 0; i < values.length; i++) {
      if (correct[i]) {
        canvas.drawPath(
          layout.regionPath(i),
          Paint()..color = AppColors.ok.withValues(alpha: 0.35),
        );
      }
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(layout.pathA, stroke..color = AppColors.library);
    canvas.drawPath(layout.pathB, stroke..color = AppColors.gold);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.chalk.withValues(alpha: 0.4),
    );

    final r = layout.radius;
    _text(canvas, 'U', const Offset(16, 16), 14, AppColors.chalk);
    _text(
      canvas,
      'A',
      layout.centerA + Offset(-r * 0.5, -r * 0.72),
      16,
      AppColors.library,
    );
    _text(
      canvas,
      'B',
      layout.centerB + Offset(r * 0.5, -r * 0.72),
      16,
      AppColors.gold,
    );
    for (var i = 0; i < values.length; i++) {
      _text(
        canvas,
        values[i]?.toString() ?? '?',
        layout.labelPosition(i),
        22,
        correct[i] ? AppColors.ok : AppColors.chalk,
      );
    }
  }

  void _text(Canvas canvas, String s, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_VennPainter old) => true;
}

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({required this.title, this.initial});
  final String title;
  final int? initial;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  late final _controller = TextEditingController(
    text: widget.initial?.toString() ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ok() => Navigator.pop(context, int.tryParse(_controller.text.trim()));

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(hintText: 'Quants alumnes?'),
      onSubmitted: (_) => _ok(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel·la'),
      ),
      FilledButton(onPressed: _ok, child: const Text("D'acord")),
    ],
  );
}
