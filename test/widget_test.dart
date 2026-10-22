import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/main.dart';

void main() {
  testWidgets('learning home quick actions open their destinations', (tester) async {
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('İngilizceyi, adım adım keşfet.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Bugün İngilizceye küçük bir adım at.'), findsOneWidget);
    expect(find.text('Bir hikâyeyle başla'), findsOneWidget);

    await tester.tap(find.text('Hikâyeleri keşfet'));
    await tester.pumpAndSettle();
    expect(find.text('Okuma ve hikâyeler'), findsOneWidget);
    expect(find.text("Tom's Morning"), findsOneWidget);

    await tester.tap(find.text("Tom's Morning"));
    await tester.pumpAndSettle();
    expect(find.text("Tom her sabah erken uyanır."), findsOneWidget);
    expect(find.text('wakes up · uyanır'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kelimeler').first);
    await tester.pumpAndSettle();
    expect(find.text('Kelime alanı hazırlanıyor'), findsOneWidget);

    await tester.tap(find.text('Pratik').first);
    await tester.pumpAndSettle();
    expect(find.text('Alıştırmalar burada olacak'), findsOneWidget);

    await tester.tap(find.text('Keşfet').first);
    await tester.pumpAndSettle();
    expect(find.text('Okuma ve hikâyeler'), findsOneWidget);

    await tester.tap(find.text('Öğren').first);
    await tester.pumpAndSettle();
    expect(find.text('Bugün İngilizceye küçük bir adım at.'), findsOneWidget);

    final practiceAction = find.text('Kısa bir pratik yap');
    await tester.ensureVisible(practiceAction);
    await tester.tap(practiceAction);
    await tester.pumpAndSettle();
    expect(find.text('Alıştırmalar burada olacak'), findsOneWidget);
  });
}
