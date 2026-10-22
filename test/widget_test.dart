import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/main.dart';

void main() {
  testWidgets('splash screen opens the four-tab app', (tester) async {
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('İngilizceyi, adım adım keşfet.'), findsOneWidget);

    // Allow the short splash delay and route transition to complete.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenmeye devam et.'), findsOneWidget);

    await tester.tap(find.text('Kelimeler').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Sözlük arama, kaydedilen kelimeler ve aralıklı tekrar akışı ayrı bir adımda eklenecek.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Pratik').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Cümle kurma, dil bilgisi, dinleme ve kelime oyunları bu sekmede toplanacak.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Keşfet').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Hikâyeler ve serbest okunabilir içerikler bu alana bağlanacak.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Öğren').first);
    await tester.pumpAndSettle();
    expect(find.text('Öğrenmeye devam et.'), findsOneWidget);
  });
}
