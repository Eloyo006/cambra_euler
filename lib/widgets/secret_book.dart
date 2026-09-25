import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/content.dart';
import '../state/game_state.dart';

/// El llibre amagat de la Biblioteca. Brilla fins que s'obre.
class SecretBookCard extends ConsumerStatefulWidget {
  const SecretBookCard({super.key});

  @override
  ConsumerState<SecretBookCard> createState() => _SecretBookCardState();
}

class _SecretBookCardState extends ConsumerState<SecretBookCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (!ref.read(gameProvider).bookOpened) _glow.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    ref.read(gameProvider.notifier).openBook();
    _glow.stop();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.menu_book, color: AppColors.gold, size: 40),
        title: const Text("El quadern d'Euler"),
        content: const Text(secretBookText),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tanca'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opened = ref.watch(gameProvider.select((s) => s.bookOpened));
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: opened
              ? null
              : [
                  BoxShadow(
                    color: AppColors.gold.withValues(
                      alpha: 0.25 + 0.45 * _glow.value,
                    ),
                    blurRadius: 8 + 14 * _glow.value,
                  ),
                ],
        ),
        child: child,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          minTileHeight: 64,
          leading: const Icon(Icons.auto_stories, color: AppColors.gold),
          title: Text(opened ? "El quadern d'Euler" : secretBookTitle),
          subtitle: Text(opened ? 'Torna a llegir-lo' : 'Abans no hi era…'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _open,
        ),
      ),
    );
  }
}
