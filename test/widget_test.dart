// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_finance_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization
    await tester.pumpAndSettle();
    
    // Verify app launched (any widget exists)
    expect(tester.allWidgets.isNotEmpty, true);
  });
}
