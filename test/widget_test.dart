import 'package:flutter_test/flutter_test.dart';
import 'package:project_mini_game_racing/main.dart';

void main() {
  testWidgets('Shadow Derby smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShadowDerbyApp());
    expect(find.text('SHADOW DERBY'), findsOneWidget);
  });
}
