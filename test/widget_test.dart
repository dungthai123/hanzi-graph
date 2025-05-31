// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hanzi_graph/main.dart';

void main() {
  testWidgets('HanziGraph app starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HanziGraphApp());

    // Verify that the app shows loading screen initially
    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('HanziGraph'), findsOneWidget);

    // Wait for initialization to complete
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // After initialization, we should see the main app
    expect(find.text('Loading...'), findsNothing);
  });
}
