import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bubixo/features/learn/presentation/lessons_screen.dart';

Future<void> pumpRouteTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump();
}

void main() {
  testWidgets('lesson flow checks an answer and opens the next lesson', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LessonsScreen()));

    expect(find.text('Adım adım öğren'), findsOneWidget);
    expect(find.text('Alfabe ve Telaffuzun Temelleri'), findsOneWidget);

    await tester.tap(find.text('Alfabe ve Telaffuzun Temelleri'));
    await pumpRouteTransition(tester);

    expect(find.text('Konu özeti'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Kendini dene'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Kendini dene'), findsOneWidget);

    final correctAnswer = find.text('w');
    await tester.scrollUntilVisible(
      correctAnswer,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    final answerTile = find.ancestor(
      of: correctAnswer,
      matching: find.byType(InkWell),
    ).first;
    await tester.tap(answerTile);
    await tester.pump();
    final checkButton = find.ancestor(
      of: find.text('Cevabı kontrol et'),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(checkButton).onPressed, isNotNull);

    await tester.scrollUntilVisible(
      find.text('Cevabı kontrol et'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Cevabı kontrol et'));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Sonraki derse geç'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Doğru!'), findsOneWidget);
    expect(find.text('Sonraki derse geç'), findsOneWidget);
    await tester.tap(find.text('Sonraki derse geç'));
    await pumpRouteTransition(tester);

    expect(find.text('Selamlaşma ve Tanışma'), findsOneWidget);
  });
}
