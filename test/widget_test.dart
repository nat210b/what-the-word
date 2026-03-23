import 'package:flutter_test/flutter_test.dart';

import 'package:toeic_apps/main.dart';

void main() {
  testWidgets('App usable without login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Me'), findsOneWidget);
    expect(find.text('สมัคร/เข้าสู่ระบบ'), findsNothing);
    expect(find.text('Vocabulary'), findsOneWidget);
  });
}
