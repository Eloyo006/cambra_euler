import 'package:cambra_euler/main.dart';
import 'package:cambra_euler/state/game_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets("L'app arrenca a la pantalla d'inici", (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: const CambraApp(),
      ),
    );
    expect(find.text("La Cambra d'Euler"), findsOneWidget);
    expect(find.text('Comença'), findsOneWidget);

    await tester.tap(find.text('Comença'));
    await tester.pumpAndSettle();
    expect(find.text('El vestíbul'), findsOneWidget);
    expect(find.text('La Biblioteca'), findsOneWidget);

    // Tornar a l'inici atura el rellotge (no queden timers pendents).
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Continua'), findsOneWidget);
  });
}
