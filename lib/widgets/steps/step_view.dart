import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/content.dart';
import '../../models/puzzle.dart';
import '../../state/settings.dart';
import '../aids/affine_table.dart';
import '../aids/caesar_wheel.dart';
import '../feedback.dart';
import 'choice_step_view.dart';
import 'expression_step_view.dart';
import 'hanoi_step_view.dart';
import 'order_step_view.dart';
import 'partition_step_view.dart';
import 'table_step_view.dart';
import 'tap_line_step_view.dart';
import 'text_answer_view.dart';
import 'venn_step_view.dart';
import 'wheel_lock_step_view.dart';

/// Envia una resposta per validar-la.
typedef SubmitAnswer = void Function(Object answer);

/// Rebutja una acció local (moviment il·legal, formulari incomplet…).
typedef RejectAction = void Function(String message);

/// Mostra el pas actual amb el widget que li toca i el feedback comú:
/// sacsejada i missatge si falla, vibració si l'encerta.
class StepView extends StatefulWidget {
  const StepView({
    super.key,
    required this.step,
    required this.onAnswer,
    this.hintsUsed = 0,
  });

  final PuzzleStep step;

  /// Pistes obertes del puzle (algunes ajudes es desbloquegen amb pistes).
  final int hintsUsed;

  /// Retorna si la resposta és correcta (normalment `GameNotifier.answer`).
  final bool Function(Object answer) onAnswer;

  @override
  State<StepView> createState() => _StepViewState();
}

class _StepViewState extends State<StepView> {
  final _shake = GlobalKey<ShakeState>();
  String? _error;

  void _submit(Object answer) {
    if (widget.onAnswer(answer)) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _error = null);
    } else {
      _reject('No és correcte. Torna-ho a provar.');
    }
  }

  void _reject(String message) {
    HapticFeedback.heavyImpact();
    Sfx.error();
    setState(() => _error = message);
    _shake.currentState?.shake();
  }

  Widget? _aidFor(TextStep s) {
    if (s.aid == StepAid.none) return null;
    if (!s.showsAid(widget.hintsUsed)) {
      return Row(
        children: [
          const Icon(Icons.lock_outline, size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Hi ha una taula d'ajuda: es desbloqueja amb la pista "
              '${s.aidMinHints} («${hintLabels[s.aidMinHints - 1]}»).',
            ),
          ),
        ],
      );
    }
    return switch (s.aid) {
      StepAid.caesarWheel => const CaesarWheel(),
      StepAid.affineTable => AffineTable(a: s.affine.a, b: s.affine.b),
      StepAid.none => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (widget.step) {
      CodeStep() => TextAnswerView(numeric: true, onSubmit: _submit),
      TextStep s => TextAnswerView(
        numeric: false,
        onSubmit: _submit,
        aid: _aidFor(s),
      ),
      ChoiceStep s => ChoiceStepView(step: s, onSubmit: _submit),
      TableStep s => TableStepView(
        step: s,
        onSubmit: _submit,
        onReject: _reject,
      ),
      VennStep s => VennStepView(step: s, onSubmit: _submit, onReject: _reject),
      ExpressionStep s => ExpressionStepView(
        step: s,
        onSubmit: _submit,
        onReject: _reject,
      ),
      PartitionStep s => PartitionStepView(
        step: s,
        onSubmit: _submit,
        onReject: _reject,
      ),
      OrderStep s => OrderStepView(step: s, onSubmit: _submit),
      HanoiStep s => HanoiStepView(
        step: s,
        onSubmit: _submit,
        onReject: _reject,
      ),
      TapLineStep s => TapLineStepView(step: s, onSubmit: _submit),
      WheelLockStep s => WheelLockStepView(step: s, onSubmit: _submit),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.step.prompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Shake(key: _shake, child: body),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _error == null
                  ? const SizedBox(width: double.infinity)
                  : Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
