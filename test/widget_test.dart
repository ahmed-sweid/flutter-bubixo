import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/main.dart';

void main() {
  testWidgets('main navigation and story reader interactions work', (tester) async {
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('İngilizceyi, adım adım keşfet.'), findsOneWidget);

    // The splash screen contains an indeterminate progress indicator, so
    // pumpAndSettle would wait forever for its animation to stop.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Bugün İngilizceye küçük bir adım at.'), findsOneWidget);
    expect(find.text('Bir hikâyeyle başla'), findsOneWidget);

    await tester.tap(find.text('Hikâyeleri keşfet'));
    await tester.pumpAndSettle();
    expect(find.text('Okuma ve hikâyeler'), findsOneWidget);
    expect(find.text("Tom's Morning"), findsOneWidget);

    await tester.tap(find.text("Tom's Morning"));
    await tester.pumpAndSettle();
    expect(find.text("Tom wakes up early every morning."), findsOneWidget);
    expect(find.text('Türkçe anlamı görmek için dokun'), findsWidgets);
    await tester.tap(find.text("Tom wakes up early every morning."));
    await tester.pumpAndSettle();
    expect(find.text('Tom her sabah erken uyanır.'), findsOneWidget);
    expect(find.text('wakes up · uyanır'), findsOneWidget);

    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Okuma ve hikâyeler'), findsOneWidget);

    await tester.tap(find.text('Kelimeler').first);
    await tester.pumpAndSettle();
    expect(find.text('Kelime listelerin'), findsOneWidget);
    expect(find.text('İngilizce veya Türkçe ara'), findsOneWidget);

    await tester.tap(find.text('Pratik').first);
    await tester.pumpAndSettle();
    expect(find.text('Alıştırma türleri'), findsOneWidget);
    expect(find.text('Cümle kurma'), findsOneWidget);

    await tester.tap(find.text('Cümle kurma').first);
    await tester.pumpAndSettle();
    expect(find.text('Cümlen'), findsOneWidget);
    expect(find.text('Cümleyi kontrol et'), findsOneWidget);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keşfet').first);
    await tester.pumpAndSettle();
    expect(find.text('Okuma ve hikâyeler'), findsOneWidget);

    await tester.tap(find.text('Öğren').first);
    await tester.pumpAndSettle();
    expect(find.text('Bugün İngilizceye küçük bir adım at.'), findsOneWidget);

    final practiceAction = find.text('Öğrendiklerini uygula');
    await tester.ensureVisible(practiceAction);
    await tester.tap(practiceAction);
    await tester.pumpAndSettle();
    expect(find.text('Alıştırma türleri'), findsOneWidget);
  });
}
