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
  VennStep(
    prompt: 'Venn',
    regions: [18, 7, 11, 4],
    labels: ['Només A', 'A ∩ B', 'Només B', 'Fora'],
  ),
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
  int hintsUsed = 0,
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
              hintsUsed: hintsUsed,
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

  testWidgets("Venn: les regions s'omplen amb el diàleg i s'envien", (
    tester,
  ) async {
    final answers = await pumpStep(tester, allSteps[4], result: true);
    const values = [18, 7, 11, 4];
    const labels = ['Només A', 'A ∩ B', 'Només B', 'Fora'];
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('${labels[i]}: ?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '${values[i]}');
      await tester.tap(find.text("D'acord"));
      await tester.pumpAndSettle();
    }
    expect(find.text('Només A: 18'), findsOneWidget);
    await tester.tap(find.text('Comprova'));
    await tester.pumpAndSettle();
    expect(answers, [values]);
  });

  testWidgets('Venn: tocar el centre del diagrama obre A ∩ B', (tester) async {
    await pumpStep(tester, allSteps[4]);
    final paint = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.size.width > 200,
    );
    await tester.tap(paint);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AlertDialog, 'A ∩ B'), findsOneWidget);
  });

  sala2Tests();

  testWidgets('Prestatgeria: tocar llibre i caixa, i arrossegar', (
    tester,
  ) async {
    final answers = await pumpStep(tester, allSteps[6], result: true);
    Finder book(int n) =>
        find.byWidgetPredicate((w) => w is Draggable<int> && w.data == n);
    Finder box(int b) => find.text('Caixa $b');

    // Buit: es rebutja.
    await tester.tap(find.text('Comprova'));
    await tester.pumpAndSettle();
    expect(find.text('Encara queden llibres al prestatge.'), findsOneWidget);

    // Llibres 1–4 tocant, 5 i 6 arrossegant.
    const target = {1: 1, 2: 2, 3: 1, 4: 2, 5: 1, 6: 3};
    for (final e in target.entries.take(4)) {
      await tester.tap(book(e.key));
      await tester.pump();
      await tester.tap(box(e.value));
      await tester.pump();
    }
    for (final e in target.entries.skip(4)) {
      await tester.drag(
        book(e.key),
        tester.getCenter(box(e.value)) - tester.getCenter(book(e.key)),
      );
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('Comprova'));
    await tester.tap(find.text('Comprova'));
    await tester.pumpAndSettle();
    expect(answers, [
      [
        {1, 3, 5},
        {2, 4},
        {6},
      ],
    ]);
  });
}

void sala2Tests() {
  testWidgets('Rodes: les fletxes giren la roda i s\'envia la combinació', (
    tester,
  ) async {
    const lock = WheelLockStep(
      prompt: 'Pany',
      symbols: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      solution: ['4', '2', '1', '3'],
      locked: [0, 2],
    );
    final answers = await pumpStep(tester, lock, result: true);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Baixa la roda 2'));
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Baixa la roda 4'));
      await tester.pumpAndSettle();
    }
    // Les rodes bloquejades no tenen fletxes.
    expect(find.byTooltip('Baixa la roda 1'), findsNothing);
    await tester.tap(find.text('Obre el pany'));
    await tester.pumpAndSettle();
    expect(answers, [
      ['4', '2', '1', '3'],
    ]);
  });

  testWidgets('Rodes: el botó «No té solució»', (tester) async {
    const lock = WheelLockStep(
      prompt: '2x ≡ 1 (mod 6)',
      symbols: ['1', '2', '3', '4', '5', '6'],
      solution: null,
      wheelCount: 1,
      offerNoSolution: true,
    );
    final answers = await pumpStep(tester, lock, result: true);
    await tester.tap(find.text('No té solució'));
    await tester.pumpAndSettle();
    expect(answers, [WheelLockStep.noSolution]);
  });

  testWidgets('Taula: marcar caselles envia els índexs', (tester) async {
    const step = TableStep(
      prompt: 'Marca',
      modulus: 5,
      mode: TableMode.markCells,
    );
    final answers = await pumpStep(tester, step, result: true);
    for (final (r, c) in [(1, 1), (2, 3), (3, 2), (4, 4)]) {
      await tester.tap(find.bySemanticsLabel('$r per $c: 1'));
      await tester.pump();
    }
    await tester.tap(find.text('Comprova'));
    await tester.pumpAndSettle();
    expect(answers, [
      {0, 7, 11, 18},
    ]);
  });

  testWidgets('Taula: omplir amb el teclat', (tester) async {
    const step = TableStep(prompt: 'Omple', modulus: 5, prefilled: [0]);
    final answers = await pumpStep(tester, step, result: true);
    // Omple totes les caselles buides amb el valor correcte.
    for (var i = 1; i < 25; i++) {
      final r = i ~/ 5 + 1, c = i % 5 + 1;
      await tester.tap(find.bySemanticsLabel('$r per $c: buida'));
      await tester.pump();
      final v = step.cell(r - 1, c - 1);
      await tester.tap(find.widgetWithText(OutlinedButton, '$v'));
      await tester.pump();
    }
    await tester.tap(find.text('Comprova'));
    await tester.pumpAndSettle();
    expect(answers, [step.solution]);
  });

  testWidgets('Taula de ℤ₆: triar els elements amb invers', (tester) async {
    const step = TableStep(
      prompt: 'Invers',
      modulus: 6,
      mode: TableMode.pickInvertible,
    );
    final answers = await pumpStep(tester, step, result: true);
    await tester.tap(find.bySemanticsLabel('Element 1'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Element 5'));
    await tester.pump();
    await tester.tap(find.text('Comprova'));
    await tester.pumpAndSettle();
    expect(answers, [
      {1, 5},
    ]);
  });

  testWidgets('Roda de César: els botons canvien el desplaçament', (
    tester,
  ) async {
    const step = TextStep(
      prompt: 'César',
      accepted: ['BON DIA'],
      aid: StepAid.caesarWheel,
    );
    await pumpStep(tester, step);
    expect(find.textContaining('Desplaçament: 0'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Gira el disc interior endavant'));
      await tester.pump();
    }
    expect(find.text('Desplaçament: 3  ·  A → D'), findsOneWidget);
    await tester.tap(find.byTooltip('Gira el disc interior enrere'));
    await tester.pump();
    expect(find.textContaining('Desplaçament: 2'), findsOneWidget);
  });

  testWidgets('Taula afí: bloquejada fins a la pista 2', (tester) async {
    const step = TextStep(
      prompt: 'Afí',
      accepted: ['LIBRO'],
      aid: StepAid.affineTable,
      aidMinHints: 2,
    );
    await pumpStep(tester, step, hintsUsed: 1);
    expect(find.text('L → Y'), findsNothing);
    expect(
      find.textContaining('es desbloqueja amb la pista 2'),
      findsOneWidget,
    );
    await pumpStep(tester, step, hintsUsed: 2);
    expect(find.text('L → Y'), findsOneWidget);
  });
}
