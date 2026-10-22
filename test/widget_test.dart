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

Future<void> pumpRouteTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump();
}

void main() {
  testWidgets('main navigation and story reader interactions work', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('İngilizceyi, adım adım keşfet.'), findsOneWidget);

    // The splash screen contains an indeterminate progress indicator, so
    // pumpAndSettle would wait forever for its animation to stop.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Bugün İngilizceye küçük bir adım at.'), findsOneWidget);
    expect(find.text('Bir hikâyeyle başla'), findsOneWidget);

    // Scroll the learning screen until the CTA is fully in view before tapping.
    final discoverAction = find.widgetWithText(FilledButton, 'Hikâyeleri keşfet');
    await tester.ensureVisible(discoverAction);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(discoverAction);
    await tester.pump(const Duration(milliseconds: 400));

    // Confirm the tab navigation happened before waiting for story assets.
    expect(find.text('Okuma ve hikâyeler'), findsOneWidget);

    // Allow the real asset-bundle future to finish outside fake test time.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await pumpUntilFound(tester, find.text("Tom's Morning"));
    expect(find.text("Tom's Morning"), findsOneWidget);

    final firstStory = find.text("Tom's Morning");
    await tester.ensureVisible(firstStory);
    await tester.tap(firstStory);
    await pumpRouteTransition(tester);
    final firstSentence = find.text("Tom wakes up early every morning.");
    await tester.scrollUntilVisible(
      firstSentence,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(firstSentence, findsOneWidget);
    await tester.tap(firstSentence);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Tom her sabah erken uyanır.'), findsOneWidget);
    expect(find.text('wakes up · uyanır'), findsOneWidget);

    // Saving a phrase from the reader should make it available in vocabulary.
    await tester.tap(find.text('wakes up · uyanır'));
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.byTooltip('Geri'));
    await pumpRouteTransition(tester);
    // The story list keeps its scroll position when returning from the reader.
    expect(find.text("Tom's Morning"), findsOneWidget);

    await tester.tap(find.text('Kelimeler').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Kelime listelerin'), findsOneWidget);
    expect(find.text('İngilizce veya Türkçe ara'), findsOneWidget);
    await tester.tap(find.text('Kaydedilenler'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('wakes up'), findsOneWidget);

    await tester.tap(find.text('Pratik').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Alıştırma türleri'), findsOneWidget);
    expect(find.text('Cümle kurma'), findsOneWidget);

    await tester.tap(find.text('Cümle kurma').first);
    await pumpRouteTransition(tester);
    expect(find.text('Cümlen'), findsOneWidget);
    expect(find.text('Cümleyi kontrol et'), findsOneWidget);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Keşfet').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("Tom's Morning"), findsOneWidget);

    await tester.tap(find.text('Öğren').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    expect(find.text('Bugün İngilizceye küçük bir adım at.'), findsOneWidget);
    expect(find.text('Son hikâyene dön'), findsOneWidget);
    expect(find.text("Tom's Morning"), findsOneWidget);

    final practiceAction = find.text('Öğrendiklerini uygula');
    await tester.ensureVisible(practiceAction);
    await tester.tap(practiceAction);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Alıştırma türleri'), findsOneWidget);
  });
}
