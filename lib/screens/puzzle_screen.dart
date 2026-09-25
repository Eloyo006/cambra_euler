import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/content.dart';
import '../models/puzzle.dart';
import '../state/game_state.dart';
import '../widgets/feedback.dart';
import '../widgets/mod_clock.dart';
import '../widgets/steps/step_view.dart';
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
  String? _success;

  /// Pas que s'acaba de resoldre (per animar-ne el check).
  int? _justSolved;

  Puzzle get _puzzle => widget.puzzle;
  Color get _color => widget.room?.color ?? AppColors.gold;

  bool _answer(Object answer) {
    final index = ref.read(gameProvider).stepsDone(_puzzle);
    final ok = ref.read(gameProvider.notifier).answer(_puzzle, answer);
    if (!ok) {
      setState(() => _success = null);
      return false;
    }
    setState(() {
      _success = _puzzle.steps[index].success ?? 'Correcte!';
      _justSolved = index;
    });
    if (ref.read(gameProvider).finished) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const VictoryScreen()),
        (route) => route.isFirst,
      );
    }
    return true;
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
            if (_puzzle.id == finalPuzzle.id) ...[
              const SizedBox(height: 12),
              s.bookOpened
                  ? const _InfoCard(
                      icon: Icons.auto_stories,
                      color: AppColors.gold,
                      title: "El quadern d'Euler",
                      body: secretBookText,
                    )
                  : _InfoCard(
                      icon: Icons.help_outline,
                      color: AppColors.chalk.withValues(alpha: 0.6),
                      title: 'Et falta alguna cosa',
                      body: secretBookMissing,
                    ),
            ],
            const SizedBox(height: 16),
            for (var i = 0; i < done && i < _puzzle.steps.length; i++)
              _SolvedStep(step: _puzzle.steps[i], animate: i == _justSolved),
            if (!solved)
              StepView(
                key: ValueKey('${_puzzle.id}-$done'),
                step: _puzzle.steps[done],
                onAnswer: _answer,
              ),
            if (_success != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _success!,
                  style: const TextStyle(color: AppColors.ok),
                ),
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

class _SolvedStep extends StatelessWidget {
  const _SolvedStep({required this.step, this.animate = false});
  final PuzzleStep step;
  final bool animate;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: AnimatedCheck(animate: animate),
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
