import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Versió base: un camp numèric per regió. Les regions encertades
/// s'il·luminen després de comprovar. (El diagrama amb CustomPaint arriba
/// a la Fase 3.)
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
  late final _controllers = [
    for (final _ in widget.step.regions) TextEditingController(),
  ];
  List<bool>? _correct;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final values = [for (final c in _controllers) int.tryParse(c.text.trim())];
    setState(() => _correct = widget.step.correctRegions(values));
    if (values.contains(null)) {
      widget.onReject('Escriu un nombre a cada regió.');
      return;
    }
    widget.onSubmit(values.cast<int>().toList());
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < _controllers.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            controller: _controllers[i],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: widget.step.labels[i],
              enabledBorder: _correct?[i] == true
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.ok,
                        width: 2,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      FilledButton(onPressed: _submit, child: const Text('Comprova')),
    ],
  );
}
