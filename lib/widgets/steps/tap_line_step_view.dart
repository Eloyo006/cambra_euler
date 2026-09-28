import 'package:flutter/material.dart';

import '../../core/typography.dart';
import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// La prova es mostra línia a línia i l'alumne toca la que falla.
class TapLineStepView extends StatelessWidget {
  const TapLineStepView({
    super.key,
    required this.step,
    required this.onSubmit,
  });

  final TapLineStep step;
  final SubmitAnswer onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < step.lines.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSubmit(i),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}.',
                        style: const TextStyle(color: AppColors.gold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(keepMathTogether(step.lines[i]))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
