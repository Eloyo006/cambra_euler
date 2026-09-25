import 'package:cambra_euler/core/theme.dart';
import 'package:cambra_euler/models/puzzle.dart';
import 'package:cambra_euler/widgets/steps/step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un pas de cada tipus, amb dades semblants a les del joc.
const allSteps = <PuzzleStep>[
  CodeStep(prompt: 'Codi', solution: '7'),
  TextStep(prompt: 'Text', accepted: ['LIBRO']),
  ChoiceStep(prompt: 'Tria', options: ['a', 'b'], correctIndex: 1),
  TableStep(prompt: 'Taula', modulus: 5, prefilled: [1, 5, 7, 8, 9]),
  VennStep(prompt: 'Venn', regions: [18, 7, 11, 4]),
  ExpressionStep(prompt: 'Expr', target: '(A∪B)′', solution: 'A′ ∩ B′'),
  PartitionStep(prompt: 'Partició', items: [1, 2, 3, 4, 5, 6], boxes: 3),
  OrderStep(
    prompt: 'Ordena',
    lines: ['Cas base: (1+a)⁰ = 1 = 1 + a·0', 'Hipòtesi', 'Conclusió'],
    initialOrder: [2, 0, 1],
  ),
  HanoiStep(prompt: 'Hanoi', discs: 4),
  TapLineStep(prompt: 'Toca', lines: ['n = 1', 'k → k+1'], wrongLine: 1),
  WheelLockStep(
    prompt: 'Pany',
    symbols: ['1', '2', '3', '4', '5', '6', '7'],
    solution: ['5', '3', '5', '5', '4'],
    locked: [1, 3, 4],
  ),
];

Future<List<Object>> pumpStep(
  WidgetTester tester,
  PuzzleStep step, {
  bool result = false,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final answers = <Object>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StepView(
              step: step,
              onAnswer: (a) {
                answers.add(a);
                return result;
              },
            ),
          ],
        ),
      ),
    ),
  );
  return answers;
}

void main() {
  for (final step in allSteps) {
    testWidgets('${step.runtimeType} es dibuixa a 360 dp sense errors', (
      tester,
    ) async {
      await pumpStep(tester, step);
      expect(tester.takeException(), isNull);
      expect(find.text(step.prompt), findsOneWidget);
    });
  }

  testWidgets('resposta incorrecta: missatge d\'error', (tester) async {
    final answers = await pumpStep(tester, allSteps[2]);
    await tester.tap(find.text('a'));
    await tester.pumpAndSettle();
    expect(answers, [0]);
    expect(find.text('No és correcte. Torna-ho a provar.'), findsOneWidget);
  });

  testWidgets('resposta correcta: sense missatge d\'error', (tester) async {
    final answers = await pumpStep(tester, allSteps[2], result: true);
    await tester.tap(find.text('b'));
    await tester.pumpAndSettle();
    expect(answers, [1]);
    expect(find.text('No és correcte. Torna-ho a provar.'), findsNothing);
  });

  testWidgets('taula incompleta: es rebutja sense enviar', (tester) async {
    final answers = await pumpStep(tester, allSteps[3]);
    await tester.tap(find.text('Comprova'));
    await tester.pumpAndSettle();
    expect(answers, isEmpty);
    expect(find.text('Omple totes les caselles.'), findsOneWidget);
  });

  testWidgets('Hanoi: un moviment il·legal es rebutja', (tester) async {
    final answers = await pumpStep(tester, allSteps[8]);
    final pegs = find.bySemanticsLabel(RegExp('^Agulla'));
    // Disc 1 → agulla 2, i després disc 2 → agulla 2 (sobre el petit).
    await tester.tap(pegs.at(0));
    await tester.tap(pegs.at(1));
    await tester.tap(pegs.at(0));
    await tester.tap(pegs.at(1));
    await tester.pumpAndSettle();
    expect(answers, isEmpty);
    expect(
      find.text('No pots posar un disc gran sobre un de més petit.'),
      findsOneWidget,
    );
    expect(find.textContaining('Moviments: 1'), findsOneWidget);
  });
}
