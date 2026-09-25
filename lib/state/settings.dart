import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_state.dart';

const String soundKey = 'cambra_euler_sound';

/// Sons del joc amb els sons del sistema (sense fitxers d'àudio ni
/// dependències). Es poden silenciar amb [soundProvider].
abstract final class Sfx {
  static bool enabled = true;

  /// Clic d'una roda o d'un disc.
  static void click() {
    if (enabled) SystemSound.play(SystemSoundType.click);
  }

  /// Error (en plataformes que ho suporten; a Android és el clic).
  static void error() {
    if (enabled) SystemSound.play(SystemSoundType.alert);
  }
}

final soundProvider = NotifierProvider<SoundNotifier, bool>(SoundNotifier.new);

class SoundNotifier extends Notifier<bool> {
  @override
  bool build() {
    final on = ref.read(prefsProvider).getBool(soundKey) ?? true;
    Sfx.enabled = on;
    return on;
  }

  void toggle() {
    state = !state;
    Sfx.enabled = state;
    ref.read(prefsProvider).setBool(soundKey, state);
  }
}

/// Botó per activar o silenciar el so.
class SoundToggle extends ConsumerWidget {
  const SoundToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(soundProvider);
    return IconButton(
      tooltip: on ? 'Silencia el so' : 'Activa el so',
      onPressed: ref.read(soundProvider.notifier).toggle,
      icon: Icon(on ? Icons.volume_up : Icons.volume_off),
    );
  }
}
