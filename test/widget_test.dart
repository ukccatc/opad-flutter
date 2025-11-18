import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_opad/main.dart';

void main() {
  testWidgets('OPAD app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OpadApp());

    // Verify that our welcome text is present
    expect(find.text('Welcome to OPAD'), findsOneWidget);
    expect(find.text('Flutter Web Application'), findsOneWidget);
  });
}
