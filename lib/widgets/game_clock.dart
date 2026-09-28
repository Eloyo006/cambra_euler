import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/puzzle.dart';
import '../state/game_state.dart';

/// Cronòmetre de la barra superior. Mostra el temps total de la partida i,
/// dins d'un puzle, també el temps d'aquell puzle (real + pistes).
class GameClock extends ConsumerWidget {
  const GameClock({super.key, this.puzzle, this.color = AppColors.gold});

  /// Puzle obert, o `null` al vestíbul i a les sales.
  final Puzzle? puzzle;

  /// Color del text (per contrastar amb la barra).
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(gameProvider.select((s) => s.total));
    final p = puzzle;
    final own = p == null
        ? null
        : ref.watch(gameProvider.select((s) => s.puzzleTime(p)));
    final style = TextStyle(
      color: color,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (own == null) {
      return Semantics(
        label: 'Temps total ${formatTime(total)}',
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 20, color: color),
            const SizedBox(width: 6),
            Text(formatTime(total), style: style),
          ],
        ),
      );
    }

    final small = style.copyWith(fontSize: 13, height: 1.25);
    return Semantics(
      label:
          'Temps total ${formatTime(total)}, '
          'temps en aquest enigma ${formatTime(own)}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Total ${formatTime(total)}', style: small),
          Text(
            'Enigma ${formatTime(own)}',
            style: small.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
