import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Constructor d'expressions amb fitxes (A′, B′, A, B, ∩, ∪, parèntesis).
class ExpressionStepView extends StatefulWidget {
  const ExpressionStepView({
    super.key,
    required this.step,
    required this.onSubmit,
    required this.onReject,
  });

  final ExpressionStep step;
  final SubmitAnswer onSubmit;
  final RejectAction onReject;

  @override
  State<ExpressionStepView> createState() => _ExpressionStepViewState();
}

class _ExpressionStepViewState extends State<ExpressionStepView> {
  final List<String> _tokens = [];

  void _submit() {
    if (_tokens.isEmpty) {
      widget.onReject('Construeix una expressió amb les fitxes.');
      return;
    }
    widget.onSubmit(List<String>.of(_tokens));
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        label: 'Expressió: ${_tokens.join(' ')}',
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: Text(
            _tokens.isEmpty ? 'Toca les fitxes…' : _tokens.join(' '),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: _tokens.isEmpty
                  ? AppColors.chalk.withValues(alpha: 0.5)
                  : AppColors.chalk,
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in widget.step.tokens)
            SizedBox(
              width: 56,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                ),
                onPressed: () => setState(() => _tokens.add(t)),
                child: Text(t, style: const TextStyle(fontSize: 20)),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _tokens.isEmpty
                  ? null
                  : () => setState(() => _tokens.removeLast()),
              icon: const Icon(Icons.backspace_outlined),
              label: const Text('Esborra'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _tokens.isEmpty ? null : () => setState(_tokens.clear),
              icon: const Icon(Icons.clear),
              label: const Text('Buida'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      FilledButton(onPressed: _submit, child: const Text('Comprova')),
    ],
  );
}
