import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bubixo/features/words/presentation/words_screen.dart';

void main() {
  testWidgets('vocabulary filters fit a narrow screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: WordsScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tüm kelimeler'), findsOneWidget);
    expect(find.text('Kaydedilenler'), findsOneWidget);
    expect(find.text('Tekrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
