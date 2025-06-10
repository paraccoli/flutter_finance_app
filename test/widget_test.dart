// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_finance_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify app launched (any widget exists)
    expect(tester.allWidgets.isNotEmpty, true);
    
    // Wait for splash screen with timeout
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    
    // The app should be showing splash screen initially
    expect(find.text('Money:G'), findsOneWidget);
  });
}
