// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_graph/main.dart';
import 'package:hanzi_graph/core/app_initializer.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a mock app initializer for testing
    final appInitializer = AppInitializer();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(appInitializer: appInitializer));

    // Verify that the app starts with the walkthrough
    expect(find.text('Welcome to HanziGraph'), findsOneWidget);
  });
}
