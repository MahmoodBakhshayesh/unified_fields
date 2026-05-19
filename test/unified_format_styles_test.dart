import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  group('UnifiedFieldsDateFormatStyle', () {
    test('gregorian day uses pattern', () {
      const style = UnifiedFieldsDateFormatStyle(
        gregorianDayPattern: 'yyyy-MM-dd',
      );
      final text = style.format(
        DateTime(2024, 8, 3),
        calendarKind: UnifiedFieldsCalendarKind.gregorian,
      );
      expect(text, '2024-08-03');
    });

    test('jalali day uses Persian month name', () {
      const style = UnifiedFieldsDateFormatStyle.standard;
      final text = style.format(
        DateTime(2024, 8, 3),
        calendarKind: UnifiedFieldsCalendarKind.jalali,
      );
      expect(text, contains('مرداد'));
    });

    test('range uses custom separator', () {
      const style = UnifiedFieldsDateFormatStyle(rangeSeparator: ' to ');
      final text = style.formatRange(
        DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 2),
        ),
        calendarKind: UnifiedFieldsCalendarKind.gregorian,
      );
      expect(text, contains(' to '));
      expect(text, isNot(contains('–')));
    });
  });

  group('UnifiedFieldsDurationFormatStyle', () {
    test('uses custom separator', () {
      const style = UnifiedFieldsDurationFormatStyle(partSeparator: '·');
      final text = style.format(
        const Duration(hours: 1, minutes: 5, seconds: 9),
        const [
          UnifiedFieldsDurationColumn.hour,
          UnifiedFieldsDurationColumn.minute,
          UnifiedFieldsDurationColumn.second,
        ],
      );
      expect(text, '01·05·09');
    });
  });

  test('resolve helpers prefer field over theme', () {
    const field = UnifiedFieldsDateFormatStyle(gregorianDayPattern: 'dd/MM/yyyy');
    const theme = UnifiedFieldsDateFormatStyle.standard;
    expect(
      resolveUnifiedDateFormatStyle(field: field, theme: theme),
      field,
    );
    expect(
      resolveUnifiedDateFormatStyle(theme: theme).gregorianDayPattern,
      UnifiedFieldsDateFormatStyle.standard.gregorianDayPattern,
    );
  });
}
