import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/content.dart';
import '../models/puzzle.dart';
import '../state/game_state.dart';
import '../widgets/mod_clock.dart';
import '../widgets/secret_book.dart';
import 'puzzle_screen.dart';

class RoomScreen extends ConsumerWidget {
  const RoomScreen({super.key, required this.room});
  final Room room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
        backgroundColor: room.color,
        actions: const [ModClock(), SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              room.topic.toUpperCase(),
              style: text.labelLarge?.copyWith(color: room.color),
            ),
            const SizedBox(height: 8),
            Text(
              room.intro,
              style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            for (final p in room.puzzles)
              _PuzzleTile(room: room, puzzle: p, state: s),
            if (room.id == secretBookRoom && s.bookAvailable)
              const SecretBookCard(),
            if (s.isRoomSolved(room)) ...[
              const SizedBox(height: 16),
              Card(
                color: room.color.withValues(alpha: 0.25),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Sala superada! Has obtingut la xifra ${room.digit}, '
                    'que va a la posició ${room.digitPosition} del pany.',
                    style: text.titleMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    required this.room,
    required this.puzzle,
    required this.state,
  });

  final Room room;
  final Puzzle puzzle;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final unlocked = state.isUnlocked(room, puzzle);
    final solved = state.isSolved(puzzle);
    return Card(
      child: ListTile(
        minTileHeight: 64,
        enabled: unlocked,
        leading: Icon(
          solved
              ? Icons.check_circle
              : unlocked
              ? Icons.extension
              : Icons.lock,
          color: solved ? AppColors.ok : room.color,
        ),
        title: Text('${puzzle.id} · ${puzzle.title}'),
        subtitle: Text(
          [
            solved
                ? 'Resolt'
                : unlocked
                ? puzzle.source
                : "Resol l'enigma anterior",
            if (puzzle.optional) 'Opcional · −${puzzle.bonus} s',
          ].join('\n'),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PuzzleScreen(puzzle: puzzle, room: room),
          ),
        ),
      ),
    );
  }
}
