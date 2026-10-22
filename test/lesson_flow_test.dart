import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bubixo/features/learn/presentation/lessons_screen.dart';

void main() {
  testWidgets('lesson flow checks an answer and opens the next lesson', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LessonsScreen()));

    expect(find.text('Adım adım öğren'), findsOneWidget);
    expect(find.text('Alfabe ve Telaffuzun Temelleri'), findsOneWidget);

    await tester.tap(find.text('Alfabe ve Telaffuzun Temelleri'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Konu özeti'), findsOneWidget);
    expect(find.text('Kendini dene'), findsOneWidget);
    expect(find.text('Cevabı kontrol et'), findsOneWidget);

    final correctAnswer = find.text('w');
    await tester.ensureVisible(correctAnswer);
    await tester.tap(correctAnswer);
    await tester.pump();

    await tester.ensureVisible(find.text('Cevabı kontrol et'));
    await tester.tap(find.text('Cevabı kontrol et'));
    await tester.pump();

    expect(find.textContaining('Doğru!'), findsOneWidget);
    expect(find.text('Sonraki derse geç'), findsOneWidget);

    await tester.ensureVisible(find.text('Sonraki derse geç'));
    await tester.tap(find.text('Sonraki derse geç'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Selamlaşma ve Tanışma'), findsOneWidget);
  });
}
