import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextbus/main.dart'; // Adjust import if needed

void main() {
  testWidgets('AppInitializer shows loading indicator initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppInitializer());

    // Verify that our initial state shows the loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });
}
