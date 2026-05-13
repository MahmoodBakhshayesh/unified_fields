// Smoke test for the unified_fields example app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unified_fields_example/main.dart';

void main() {
  testWidgets('Demo app renders the form', (WidgetTester tester) async {
    await tester.pumpWidget(const UnifiedFieldsDemoApp());
    await tester.pump();

    expect(find.text('unified_fields demo'), findsOneWidget);
    expect(find.text('Validate + Save'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
