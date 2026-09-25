import 'package:flutter/material.dart';

import 'step_view.dart';

/// Camp de text + «Comprova». Serveix per a [CodeStep] i [TextStep].
class TextAnswerView extends StatefulWidget {
  const TextAnswerView({
    super.key,
    required this.numeric,
    required this.onSubmit,
    this.aid,
  });

  final bool numeric;
  final SubmitAnswer onSubmit;

  /// Ajuda visual opcional que es mostra damunt del camp.
  final Widget? aid;

  @override
  State<TextAnswerView> createState() => _TextAnswerViewState();
}

class _TextAnswerViewState extends State<TextAnswerView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.aid != null) ...[widget.aid!, const SizedBox(height: 12)],
      TextField(
        controller: _controller,
        keyboardType: widget.numeric
            ? TextInputType.number
            : TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        enableSuggestions: false,
        decoration: const InputDecoration(hintText: 'Resposta'),
        onSubmitted: widget.onSubmit,
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () => widget.onSubmit(_controller.text),
        child: const Text('Comprova'),
      ),
    ],
  );
}
