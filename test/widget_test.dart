import 'helpers.dart';
import 'package:cambra_euler/core/theme.dart';
import 'package:cambra_euler/data/content.dart';
import 'package:cambra_euler/main.dart';
import 'package:cambra_euler/screens/intro_screen.dart';
import 'package:cambra_euler/screens/victory_screen.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:cambra_euler/state/ranking.dart';
import 'package:cambra_euler/state/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> pumpApp(
  WidgetTester tester, [
  Map<String, Object> prefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(overrides: testOverrides(p), child: const CambraApp()),
  );
  return p;
}

void main() {
  testWidgets("L'app arrenca, passa per la intro i arriba al vestíbul", (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text("La Cambra d'Euler"), findsOneWidget);
    expect(find.text('Comença'), findsOneWidget);

    await tester.tap(find.text('Comença'));
    await tester.pumpAndSettle();
    expect(find.byType(IntroScreen), findsOneWidget);
    await tester.tap(find.text('Salta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Endavant'));
    await tester.pumpAndSettle();
    expect(find.text('El vestíbul'), findsOneWidget);
    expect(find.text('La Biblioteca'), findsOneWidget);

    // Tornar a l'inici atura el rellotge (no queden timers pendents).
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Continua'), findsOneWidget);
  });

  testWidgets('Si es surt de la intro, la partida no comença', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Comença'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Comença'), findsOneWidget);
  });

  testWidgets('La intro escriu el text lletra a lletra', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const IntroScreen(text: 'Hola, Euler'),
      ),
    );
    expect(find.text('Hola, Euler'), findsNothing);
    await tester.pump(const Duration(milliseconds: 28 * 4 + 5));
    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('Endavant'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Hola, Euler'), findsOneWidget);
    expect(find.text('Endavant'), findsOneWidget);
  });

  testWidgets('El botó de so es recorda', (tester) async {
    final prefs = await pumpApp(tester, {storageKey: '{"started": true}'});
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Silencia el so'));
    await tester.pump();
    expect(prefs.getBool(soundKey), isFalse);
    expect(Sfx.enabled, isFalse);
    expect(find.byTooltip('Activa el so'), findsOneWidget);
    await tester.tap(find.byTooltip('Activa el so'));
    await tester.pump();
    expect(Sfx.enabled, isTrue);
    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('Victòria: la porta s\'obre i es veu el rànquing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: testOverrides(prefs));
    addTearDown(container.dispose);
    container
        .read(rankingProvider.notifier)
        .add(
          const RankEntry(
            total: 900,
            elapsed: 800,
            penalty: 100,
            hints: 2,
            finishedAt: '2026-09-20T10:00:00',
          ),
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildTheme(),
          home: const VictoryScreen(playDoor: true),
        ),
      ),
    );
    expect(
      find.byIcon(Icons.lock),
      findsOneWidget,
    ); // la porta encara és tancada
    await tester.pumpAndSettle();
    expect(find.text("La porta s'obre!"), findsOneWidget);
    expect(find.text(victoryText), findsOneWidget);
    await tester.scrollUntilVisible(find.text('15:00'), 300);
    expect(find.text('Millors partides'), findsOneWidget);
    expect(find.text('15:00'), findsOneWidget);
  });
}
