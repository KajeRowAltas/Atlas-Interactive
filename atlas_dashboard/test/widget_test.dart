// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_interactive/main.dart';

void main() {
  testWidgets('Main shell renders navigation rail', (WidgetTester tester) async {
    await tester.pumpWidget(const AtlasApp());

    expect(find.text('ATLAS'), findsOneWidget);
    expect(find.text('ORACLE'), findsOneWidget);
    expect(find.text('TERMINAL'), findsOneWidget);
    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('MARKETS'), findsOneWidget);
  });
}
