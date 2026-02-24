import 'package:flutter_test/flutter_test.dart';
import 'package:medisby_roboarm/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedisbyApp());
    expect(find.text('시작 화면'), findsOneWidget);
  });
}
