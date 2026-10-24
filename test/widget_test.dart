import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubixo/main.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 20,
}) async {
  for (var i = 0; i < maxAttempts && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets(
    'four-tab navigation, story reader, and practice flow work',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const BubixoApp());

      expect(find.text('İngilizceyi, adım adım keşfet.'), findsOneWidget);

      // Let the splash transition to the app shell.
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('İngilizce yolculuğun'), findsOneWidget);
      expect(find.text('Genel bakış'), findsOneWidget);
      expect(find.text('Pratik yap'), findsNothing);

      // Stories have their own bottom-navigation destination.
      await tester.tap(find.text('Hikâyeler').last);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text("Tom's Morning"));
      expect(find.text("Tom's Morning"), findsOneWidget);

      final firstStory = find.text("Tom's Morning");
      await tester.ensureVisible(firstStory);
      await tester.tap(firstStory);
      await tester.pump(const Duration(milliseconds: 700));

      final firstSentence = find.text("Tom wakes up early every morning.");
      await tester.ensureVisible(firstSentence);
      await tester.pump(const Duration(milliseconds: 250));
      expect(firstSentence, findsOneWidget);
      await tester.tap(firstSentence);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Tom her sabah erken uyanır.'), findsOneWidget);
      expect(find.text('wakes up · uyanır'), findsOneWidget);

      // Save a vocabulary item from the story reader.
      await tester.tap(find.text('wakes up · uyanır'));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.byTooltip('Geri'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text("Tom's Morning"), findsOneWidget);
      expect(
        find.textContaining('Son okuduğun hikâyeye dön'),
        findsNothing,
      );

      await tester.tap(find.text('Kelimeler').last);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Kelime listelerin'), findsOneWidget);
      expect(find.text('İngilizce veya Türkçe ara'), findsOneWidget);
      await tester.tap(find.text('Kaydedilenler'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('wakes up'), findsOneWidget);

      await tester.tap(find.text('Pratik').last);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Alıştırma türleri'), findsOneWidget);
      expect(find.text('Cümle kurma'), findsOneWidget);
      expect(find.text('Hikâye okuma'), findsNothing);

      await tester.tap(find.text('Cümle kurma').first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Cümlen'), findsOneWidget);
      expect(find.text('Cümleyi kontrol et'), findsOneWidget);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Öğren').last);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump();
      expect(find.text('İngilizce yolculuğun'), findsOneWidget);
      expect(find.text('Genel bakış'), findsOneWidget);
      expect(find.text('Küçük adımlar, kalıcı ilerleme.'), findsOneWidget);
      expect(find.text('Pratik yap'), findsNothing);
      expect(find.text('Cümle kurma'), findsNothing);
    },
  );
}
