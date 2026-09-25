import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'state/game_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const CambraApp(),
    ),
  );
}

class CambraApp extends ConsumerStatefulWidget {
  const CambraApp({super.key});

  @override
  ConsumerState<CambraApp> createState() => _CambraAppState();
}

class _CambraAppState extends ConsumerState<CambraApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// El rellotge s'atura quan l'app passa a segon pla.
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    final game = ref.read(gameProvider.notifier);
    if (s == AppLifecycleState.resumed) {
      game.resume();
    } else if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden) {
      game.pause();
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "La Cambra d'Euler",
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeScreen(),
      );
}
