import 'package:flutter_test/flutter_test.dart';
import 'package:learnword/main.dart';

void main() {
  testWidgets('LearnWordApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnWordApp());
    expect(find.text('LearnWord'), findsWidgets);
  });
}
