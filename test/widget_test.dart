import 'package:flutter_test/flutter_test.dart';
import 'package:tokosaya/main.dart';

void main() {
  testWidgets('Warung Madura POS smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WarungMaduraApp());
    expect(find.text('Kasir'), findsWidgets);
  });
}
