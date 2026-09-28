// Flux complet a través de la UI: inici → sala → puzle → pista → resolució.
import 'helpers.dart';
import 'package:cambra_euler/core/typography.dart';
import 'package:cambra_euler/main.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> tapVisible(WidgetTester tester, Finder f) async {
  // Els ListView només construeixen el que és a prop de la pantalla.
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('inici → sala → puzle → pista → resolució', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: testOverrides(prefs));
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const CambraApp()),
    );

    // Inici i intro.
    await tapVisible(tester, find.text('Comença'));
    // Segons el ritme, el text ja pot estar escrit del tot.
    if (find.text('Salta').evaluate().isNotEmpty) {
      await tapVisible(tester, find.text('Salta'));
    }
    await tapVisible(tester, find.text('Endavant'));
    expect(find.text('El vestíbul'), findsOneWidget);

    // Sala 1.
    await tapVisible(tester, find.text('La Biblioteca'));
    final p11 = rooms.first.puzzles.first;
    await tapVisible(tester, find.text('${p11.id} · ${p11.title}'));
    expect(find.text(keepMathTogether(p11.statement)), findsOneWidget);

    // Pista 1 (+30 s).
    await tapVisible(tester, find.textContaining('Demana una pista'));
    await tapVisible(tester, find.text('Obre-la'));
    expect(find.text(p11.hints[0]), findsOneWidget);
    expect(container.read(gameProvider).penalty, 30);

    // Pas 1: el diagrama de Venn (amb un error primer).
    Future<void> fillRegion(String label, int value) async {
      await tapVisible(tester, find.text('$label: ?'));
      await tester.enterText(find.byType(TextField), '$value');
      await tapVisible(tester, find.text("D'acord"));
    }

    await fillRegion('Només A', 25); // error típic: 25 en lloc de 18
    await fillRegion('A ∩ B', 7);
    await fillRegion('Només B', 11);
    await fillRegion('Cap dels dos', 4);
    await tapVisible(tester, find.text('Comprova'));
    expect(find.text('No és correcte. Torna-ho a provar.'), findsOneWidget);
    expect(container.read(gameProvider).stepsDone(p11), 0);

    await tapVisible(tester, find.text('Només A: 25'));
    await tester.enterText(find.byType(TextField), '18');
    await tapVisible(tester, find.text("D'acord"));
    await tapVisible(tester, find.text('Comprova'));
    expect(container.read(gameProvider).stepsDone(p11), 1);

    // Pas 2: |A ∪ B|.
    await tester.enterText(find.byType(TextField), '36');
    await tapVisible(tester, find.text('Comprova'));
    expect(container.read(gameProvider).isSolved(p11), isTrue);
    expect(find.text('Torna'), findsOneWidget);

    // Torna a la sala: el 1.1 surt resolt i el 1.2 desbloquejat.
    await tapVisible(tester, find.text('Torna'));
    expect(find.text('Resolt'), findsOneWidget);

    // Surt fins a l'inici (s'atura el rellotge i queda desat).
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Continua'), findsOneWidget);
    expect(prefs.getString(storageKey), contains('"1.1":2'));
  });
}
