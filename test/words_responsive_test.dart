import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bubixo/features/words/presentation/words_screen.dart';

void main() {
  testWidgets('saved story vocabulary appears in the saved filter', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'bubixo.saved_words': <String>['wakes up'],
      'bubixo.custom_words':
          '[{"english":"wakes up","turkish":"uyanır","kind":"Hikâyeden"}]',
    });

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: WordsScreen())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('wakes up'), findsOneWidget);
    await tester.tap(find.text('Kaydedilenler'));
    await tester.pumpAndSettle();
    expect(find.text('wakes up'), findsOneWidget);
  });

  testWidgets('vocabulary filters fit a narrow screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: WordsScreen())));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tüm kelimeler'), findsOneWidget);
    expect(find.text('Kaydedilenler'), findsOneWidget);
    expect(find.text('Tekrar'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
