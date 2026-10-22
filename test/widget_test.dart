import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/main.dart';

void main() {
  testWidgets('app uses the shared design-system theme', (tester) async {
    await tester.pumpWidget(const BubixoApp());

    expect(find.text('Design system'), findsOneWidget);
    expect(
      find.text('Flutter theme connected successfully.'),
      findsOneWidget,
    );
    expect(find.text('Typography'), findsOneWidget);
  });
}
