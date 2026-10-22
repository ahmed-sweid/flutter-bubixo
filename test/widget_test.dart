import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/main.dart';

void main() {
  testWidgets('four primary tabs open their respective screens', (tester) async {
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('Öğrenmeye devam et.'), findsOneWidget);

    await tester.tap(find.text('Kelimeler').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Sözlük arama, kaydedilen kelimeler ve aralıklı tekrar akışı ayrı bir adımda eklenecek.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Pratik').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Cümle kurma, dil bilgisi, dinleme ve kelime oyunları bu sekmede toplanacak.'),
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
