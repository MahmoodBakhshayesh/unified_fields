import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/src/unified_wheel_scroll_behavior.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  group('unifiedFieldsLoopingWheelIndex', () {
    test('wraps past the last value back to 0', () {
      expect(unifiedFieldsLoopingWheelIndex(60, 60), 0);
      expect(unifiedFieldsLoopingWheelIndex(24, 24), 0);
    });

    test('wraps before 0 to the last value', () {
      expect(unifiedFieldsLoopingWheelIndex(-1, 60), 59);
      expect(unifiedFieldsLoopingWheelIndex(-1, 12), 11);
      expect(unifiedFieldsLoopingWheelIndex(-2, 24), 22);
    });

    test('leaves in-range indexes unchanged', () {
      expect(unifiedFieldsLoopingWheelIndex(0, 60), 0);
      expect(unifiedFieldsLoopingWheelIndex(59, 60), 59);
      expect(unifiedFieldsLoopingWheelIndex(11, 24), 11);
    });
  });

  test('clock-style ranges loop; huge ranges do not', () {
    expect(unifiedFieldsLoopingWheelEnabled(12), isTrue);
    expect(unifiedFieldsLoopingWheelEnabled(24), isTrue);
    expect(unifiedFieldsLoopingWheelEnabled(60), isTrue);
    expect(unifiedFieldsLoopingWheelEnabled(1), isFalse);
    expect(unifiedFieldsLoopingWheelEnabled(1000), isFalse);
  });

  testWidgets('time picker wheels loop instead of stopping at the ends', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UnifiedFieldsHmsWheelPickerSheet(
            initialHours: 0,
            initialMinutes: 0,
            initialSeconds: 0,
            maxHours: 23,
            showSeconds: false,
            showCalendarKindToggle: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final wheels = tester.widgetList<ListWheelScrollView>(
      find.byType(ListWheelScrollView),
    );
    expect(wheels.length, 2);

    for (final wheel in wheels) {
      final delegate = wheel.childDelegate as ListWheelChildBuilderDelegate;
      expect(
        delegate.childCount,
        isNull,
        reason: 'null childCount lets the wheel scroll infinitely',
      );
    }
  });
}
