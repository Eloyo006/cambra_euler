import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/content.dart';
import '../state/game_state.dart';
import '../state/ranking.dart';
import '../widgets/door_opening.dart';

class VictoryScreen extends ConsumerWidget {
  const VictoryScreen({super.key, this.playDoor = false});

  /// Mostra l'animació de la porta en obrir-se (només en acabar la partida).
  final bool playDoor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final ranking = ref.watch(rankingProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: DoorOpening(
        play: playDoor,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            children: [
              const Icon(Icons.lock_open, size: 64, color: AppColors.gold),
              const SizedBox(height: 12),
              Text(
                "La porta s'obre!",
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    victoryText,
                    style: text.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
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
                    _Row(
                      'Penalització per pistes',
                      '+${formatTime(s.penalty)}',
                    ),
                    if (s.bonus > 0)
                      _Row('Bonificació', '−${formatTime(s.bonus)}'),
                    for (final r in rooms)
                      _Row('Pistes · ${r.name}', '${s.roomHints(r)}'),
                    _Row(
                      'Pistes · ${finalPuzzle.title}',
                      '${s.hintsUsed(finalPuzzle)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Millors partides', style: text.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (ranking.isEmpty)
                      const ListTile(title: Text('Encara no hi ha partides.')),
                    for (var i = 0; i < ranking.length; i++)
                      _RankRow(
                        position: i + 1,
                        entry: ranking[i],
                        current: ranking[i].finishedAt == s.finishedAt,
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

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.position,
    required this.entry,
    required this.current,
  });

  final int position;
  final RankEntry entry;
  final bool current;

  String get _date {
    final d = DateTime.tryParse(entry.finishedAt);
    if (d == null) return '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) => ListTile(
    tileColor: current ? AppColors.gold.withValues(alpha: 0.15) : null,
    leading: CircleAvatar(
      backgroundColor: current ? AppColors.gold : AppColors.slate,
      foregroundColor: current ? AppColors.ink : AppColors.chalk,
      child: Text('$position'),
    ),
    title: Text(formatTime(entry.total)),
    subtitle: Text(
      '${entry.hints} pistes · $_date${current ? ' · aquesta partida' : ''}',
    ),
  );
}
