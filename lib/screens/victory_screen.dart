import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/content.dart';
import '../state/game_state.dart';

class VictoryScreen extends ConsumerWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const Icon(Icons.lock_open, size: 64, color: AppColors.gold),
            const SizedBox(height: 12),
            Text(
              'La porta s\'obre!',
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  victoryText,
                  style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              formatTime(s.total),
              textAlign: TextAlign.center,
              style: text.displayMedium?.copyWith(color: AppColors.gold),
            ),
            Text(
              'Temps total',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _Row('Temps real', formatTime(s.elapsed)),
                  _Row('Penalització per pistes', '+${formatTime(s.penalty)}'),
                  for (final r in rooms)
                    _Row('Pistes · ${r.name}', '${s.roomHints(r)}'),
                  _Row(
                    'Pistes · ${finalPuzzle.title}',
                    '${s.hintsUsed(finalPuzzle)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Torna a l'inici"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    trailing: Text(
      value,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  );
}
