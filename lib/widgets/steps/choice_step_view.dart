import 'package:flutter/material.dart';

import '../../models/puzzle.dart';
import 'step_view.dart';

class ChoiceStepView extends StatelessWidget {
  const ChoiceStepView({super.key, required this.step, required this.onSubmit});

  final ChoiceStep step;
  final SubmitAnswer onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < step.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            onPressed: () => onSubmit(i),
            child: Text(
              step.options[i],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
    ],
  );
}
