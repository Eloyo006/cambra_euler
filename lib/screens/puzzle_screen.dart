import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/content.dart';
import '../models/puzzle.dart';
import '../state/game_state.dart';
import '../widgets/mod_clock.dart';
import 'victory_screen.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key, required this.puzzle, this.room});

  final Puzzle puzzle;

  /// `null` per a la porta final.
  final Room? room;

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  final _controller = TextEditingController();
  String? _error;
  String? _success;

  Puzzle get _puzzle => widget.puzzle;
  Color get _color => widget.room?.color ?? AppColors.gold;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(Object answer) {
    final step = _puzzle.steps[ref.read(gameProvider).stepsDone(_puzzle)];
    final ok = ref.read(gameProvider.notifier).answer(_puzzle, answer);
    setState(() {
      _error = ok ? null : 'No és correcte. Torna-ho a provar.';
      _success = ok ? (step.success ?? 'Correcte!') : null;
      if (ok) _controller.clear();
    });
    if (ok && ref.read(gameProvider).finished) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const VictoryScreen()),
        (route) => route.isFirst,
      );
    }
  }

  Future<void> _askHint(int level) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hintLabels[level]),
        content: Text(
          'Obrir aquesta pista suma ${hintPenalties[level]} s al teu temps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel·la'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Obre-la'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(gameProvider.notifier).revealHint(_puzzle);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider);
    final done = s.stepsDone(_puzzle);
    final solved = s.isSolved(_puzzle);
    final hintsUsed = s.hintsUsed(_puzzle);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_puzzle.title),
        actions: const [ModClock(), SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _puzzle.source,
              style: text.labelMedium?.copyWith(color: _color),
            ),
            const SizedBox(height: 8),
            Text(_puzzle.statement, style: text.bodyLarge),
            if (_puzzle.theory != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.menu_book,
                color: _color,
                title: 'Teoria',
                body: _puzzle.theory!,
              ),
            ],
            const SizedBox(height: 16),
            for (var i = 0; i < done && i < _puzzle.steps.length; i++)
              _SolvedStep(step: _puzzle.steps[i]),
            if (!solved) ...[
              _CurrentStep(
                key: ValueKey('step-$done'),
                step: _puzzle.steps[done],
                controller: _controller,
                onSubmit: _submit,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error)),
                ),
            ],
            if (_success != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_success!, style: const TextStyle(color: AppColors.ok)),
              ),
            if (solved) ...[
              const SizedBox(height: 16),
              if (_puzzle.outro != null)
                _InfoCard(
                  icon: Icons.auto_awesome,
                  color: AppColors.gold,
                  title: 'Enigma resolt',
                  body: _puzzle.outro!,
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Torna'),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            Text('Pistes', style: text.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < hintsUsed; i++)
              _InfoCard(
                icon: Icons.lightbulb,
                color: AppColors.gold,
                title: '${hintLabels[i]} (+${hintPenalties[i]} s)',
                body: _puzzle.hints[i],
              ),
            if (!solved && hintsUsed < hintPenalties.length)
              OutlinedButton.icon(
                onPressed: () => _askHint(hintsUsed),
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(
                  'Demana una pista: ${hintLabels[hintsUsed]} '
                  '(+${hintPenalties[hintsUsed]} s)',
                ),
              ),
            if (hintsUsed == 0 && solved)
              Text('Resolt sense pistes!', style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SolvedStep extends StatelessWidget {
  const _SolvedStep({required this.step});
  final PuzzleStep step;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: AppColors.ok),
          title: Text(step.prompt),
          subtitle: Text(
            step.solutionLabel,
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
}

class _CurrentStep extends StatelessWidget {
  const _CurrentStep({
    super.key,
    required this.step,
    required this.controller,
    required this.onSubmit,
  });

  final PuzzleStep step;
  final TextEditingController controller;
  final void Function(Object answer) onSubmit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(step.prompt, style: text.titleMedium),
            const SizedBox(height: 12),
            ...switch (step.kind) {
              StepKind.choice => [
                  for (var i = 0; i < step.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: () => onSubmit(i),
                        child: Text(step.options[i], style: text.bodyLarge),
                      ),
                    ),
                ],
              StepKind.code || StepKind.text => [
                  TextField(
                    controller: controller,
                    keyboardType: step.kind == StepKind.code
                        ? TextInputType.number
                        : TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(hintText: 'Resposta'),
                    onSubmitted: (v) => onSubmit(v),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => onSubmit(controller.text),
                    child: const Text('Comprova'),
                  ),
                ],
            },
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
        color: color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
