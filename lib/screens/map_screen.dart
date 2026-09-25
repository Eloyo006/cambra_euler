import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/content.dart';
import '../models/puzzle.dart';
import '../state/game_state.dart';
import '../state/settings.dart';
import '../widgets/mod_clock.dart';
import 'puzzle_screen.dart';
import 'room_screen.dart';

/// El vestíbul: les tres sales i la porta amb el pany «a 3 c 5 4».
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('El vestíbul'),
        actions: const [SoundToggle(), ModClock(), SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LockDisplay(state: s),
            const SizedBox(height: 16),
            for (final r in rooms) _RoomCard(room: r, state: s),
            const SizedBox(height: 8),
            _DoorCard(state: s),
          ],
        ),
      ),
    );
  }
}

/// Les xifres del pany que ja s'han guanyat. a i c es descobreixen a la porta.
List<String> lockDigits(GameState s) {
  final digits = List.filled(5, '_');
  for (final r in rooms) {
    if (s.isRoomSolved(r)) digits[r.digitPosition - 1] = '${r.digit}';
  }
  final door = s.stepsDone(finalPuzzle);
  if (door >= 1) digits[0] = finalPuzzle.steps[0].solutionLabel;
  if (door >= 2) digits[2] = finalPuzzle.steps[1].solutionLabel;
  return digits;
}

class _LockDisplay extends StatelessWidget {
  const _LockDisplay({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final digits = lockDigits(state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Text(
              'El pany de la porta',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Pany: ${digits.join(' ')}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final d in digits)
                    Container(
                      width: 44,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: d == '_'
                              ? AppColors.chalk.withValues(alpha: 0.3)
                              : AppColors.gold,
                        ),
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.state});
  final Room room;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final required = room.puzzles.where((p) => !p.optional).toList();
    final done = required.where(state.isSolved).length;
    final extra = room.puzzles.length - required.length;
    final solved = state.isRoomSolved(room);
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => RoomScreen(room: room))),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: room.color, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: room.color,
                foregroundColor: AppColors.chalk,
                child: Text('${room.number}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name, style: text.titleMedium),
                    Text(room.topic, style: text.bodySmall),
                    const SizedBox(height: 6),
                    Text(
                      '$done / ${required.length} enigmes resolts'
                      '${extra > 0 ? ' · +$extra opcional' : ''}',
                    ),
                  ],
                ),
              ),
              Icon(
                solved ? Icons.check_circle : Icons.chevron_right,
                color: solved ? AppColors.ok : AppColors.chalk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoorCard extends StatelessWidget {
  const _DoorCard({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final open = state.allRoomsSolved;
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: open
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PuzzleScreen(puzzle: finalPuzzle),
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                open ? Icons.door_front_door : Icons.lock,
                color: open
                    ? AppColors.gold
                    : AppColors.chalk.withValues(alpha: 0.5),
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(finalPuzzle.title, style: text.titleMedium),
                    Text(
                      open
                          ? 'Ja tens les tres xifres. Calcula a i c.'
                          : "Resol les tres sales per poder-t'hi acostar.",
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
