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
  testWidgets('four-tab navigation and practice activities work', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('İngilizceyi, adım adım keşfet.'), findsOneWidget);

    // Let the splash transition to the app shell.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('İngilizce yolculuğun'), findsOneWidget);
    expect(find.text('Genel bakış'), findsOneWidget);
    expect(find.text('Pratik yap'), findsNothing);

    // Stories has its own bottom-navigation destination.
    await tester.tap(find.text('Hikâyeler').last);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await pumpUntilFound(tester, find.text("Tom's Morning"));
    expect(find.text("Tom's Morning"), findsOneWidget);

    await tester.tap(find.text('Kelimeler').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Sözlükten seçmeler'), findsOneWidget);
    expect(find.text('İngilizce kelime veya cümle yaz…'), findsOneWidget);
    expect(find.text('Kaydedilenler'), findsOneWidget);

    await tester.tap(find.text('Pratik').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Alıştırma türleri'), findsOneWidget);
    expect(find.text('Cümle kurma'), findsOneWidget);
    expect(find.text('Kelime oyunları'), findsOneWidget);
    expect(find.text('Dil bilgisi'), findsOneWidget);
    expect(find.text('Hikâye okuma'), findsNothing);

    await tester.tap(find.text('Cümle kurma').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await pumpUntilFound(tester, find.text('Cümlen'));
    expect(find.text('Cümlen'), findsOneWidget);
    expect(find.text('Cümleyi kontrol et'), findsOneWidget);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Öğren').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('İngilizce yolculuğun'), findsOneWidget);
    expect(find.text('Genel bakış'), findsOneWidget);
    expect(find.text('Küçük adımlar, kalıcı ilerleme.'), findsOneWidget);
    expect(find.text('Pratik yap'), findsNothing);
    expect(find.text('Cümle kurma'), findsNothing);
  });
}
