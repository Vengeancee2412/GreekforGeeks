import 'package:flutter_test/flutter_test.dart';
import 'package:greek_for_geeks/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('GREEKFORGEEKS'), findsOneWidget);
  });
}