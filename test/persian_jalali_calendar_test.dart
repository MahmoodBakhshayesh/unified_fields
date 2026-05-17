import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  test(
    'formatUnifiedDateFieldText in jalali mode uses Shamsi month and Persian digits',
    () {
      final text = formatUnifiedDateFieldText(
        DateTime(2024, 8, 3),
        null,
        calendarKind: UnifiedFieldsCalendarKind.jalali,
      );
      expect(text, contains('مرداد'));
      expect(text, isNot(contains('Aug')));
      expect(RegExp(r'[۰-۹]').hasMatch(text), isTrue);
    },
  );

  test('formatUnifiedDateFieldText in gregorian mode stays Gregorian', () {
    final text = formatUnifiedDateFieldText(
      DateTime(2024, 8, 3),
      null,
      calendarKind: UnifiedFieldsCalendarKind.gregorian,
    );
    expect(text, contains('Aug'));
  });
}
