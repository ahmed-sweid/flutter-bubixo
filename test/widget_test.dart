import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/main.dart';

void main() {
  testWidgets('learning home quick actions open their destinations', (tester) async {
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('İngilizceyi, adım adım keşfet.'), findsOneWidget);

    // Allow the short splash delay and route transition to complete.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Bugün İngilizceye küçük bir adım at.'), findsOneWidget);
    expect(find.text('Bir hikâyeyle başla'), findsOneWidget);

    await tester.tap(find.text('Hikâyeleri keşfet'));
    await tester.pumpAndSettle();
    expect(find.text('Okuma ve hikâyeler'), findsOneWidget);

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

    await tester.tap(find.text('Kısa bir pratik yap'));
    await tester.pumpAndSettle();
    expect(find.text('Alıştırmalar burada olacak'), findsOneWidget);
  });
}
