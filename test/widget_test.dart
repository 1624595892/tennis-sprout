import 'package:flutter_test/flutter_test.dart';
import 'package:tennis_sprout/app.dart';

void main() {
  testWidgets('App loads and renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TennisSproutApp());
    await tester.pumpAndSettle();

    expect(find.text('TennisSprout'), findsOneWidget);
  });
}
