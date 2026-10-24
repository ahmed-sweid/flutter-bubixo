import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubixo/features/words/presentation/words_screen.dart';

import 'test_database_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('matches saved words regardless of stored letter case and spaces',
      (tester) async {
    await configureTestDatabaseDirectory();
    SharedPreferences.setMockInitialValues({
      'bubixo.saved_words': <String>[' GOOD '],
      'bubixo.review_words': <String>[' Good '],
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WordsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kaydedilenler'));
    await tester.pumpAndSettle();

    expect(find.text('good'), findsOneWidget);
    expect(find.text('1 kelime'), findsOneWidget);

    await tester.tap(find.text('Tekrar'));
    await tester.pumpAndSettle();

    expect(find.text('Tekrar listesi'), findsOneWidget);
    expect(find.text('good'), findsOneWidget);
    expect(find.text('1 kelime'), findsOneWidget);
  });
}
