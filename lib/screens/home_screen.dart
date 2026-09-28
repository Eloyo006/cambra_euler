import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../state/game_state.dart';
import 'intro_screen.dart';
import 'map_screen.dart';
import 'victory_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _enter(BuildContext context, WidgetRef ref) async {
    final game = ref.read(gameProvider.notifier);
    final s = ref.read(gameProvider);
    final finished = s.finished;
    // La primera vegada, la història d'Euler (el rellotge encara no corre).
    if (!s.started) {
      final go = await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) =>
              IntroScreen(text: ref.read(gameProvider).content.intro),
        ),
      );
      if (go != true || !context.mounted) return;
    }
    if (!finished) game.start();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => finished ? const VictoryScreen() : const MapScreen(),
      ),
    );
    game.leave();
  }

  Future<void> _newGame(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova partida'),
        content: const Text(
          'Es perdrà el progrés, el temps i les pistes de la partida actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel·la'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Comença de nou'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(gameProvider.notifier).reset();
    await _enter(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const Icon(Icons.lock_outline, size: 56, color: AppColors.gold),
            const SizedBox(height: 12),
            Text(
              "La Cambra d'Euler",
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(
                color: AppColors.chalk,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Escape room de FOMA · EPSEVG-UPC',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: AppColors.chalk.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(s.content.homeBlurb, style: text.bodyLarge),
              ),
            ),
            const SizedBox(height: 24),
            if (!s.started)
              FilledButton(
                onPressed: () => _enter(context, ref),
                child: const Text('Comença'),
              )
            else ...[
              FilledButton(
                onPressed: () => _enter(context, ref),
                child: Text(s.finished ? 'Mostra el resultat' : 'Continua'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(alignment: Alignment.center),
                onPressed: () => _newGame(context, ref),
                child: const Text('Nova partida'),
              ),
              const SizedBox(height: 12),
              Text(
                'Temps de la partida: ${formatTime(s.total)}',
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
