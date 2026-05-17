import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  test('toPersianDigits converts ASCII digits', () {
    expect(UnifiedFieldsTypography.toPersianDigits('1403/05/17'), '۱۴۰۳/۰۵/۱۷');
    expect(UnifiedFieldsTypography.toPersianDigits('no digits'), 'no digits');
  });

  test('fromPersianDigits converts back to ASCII', () {
    expect(UnifiedFieldsTypography.fromPersianDigits('۱۴۰۳'), '1403');
    expect(UnifiedFieldsTypography.fromPersianDigits('12'), '12');
  });

  test('localizeDigits respects Shamsi vs global flags', () {
    UnifiedFieldsTypography.instance = const UnifiedFieldsTypography(
      usePersianDigitsGlobally: false,
      usePersianDigitsInShamsi: true,
    );
    expect(
      UnifiedFieldsTypography.instance.localizeDigits(
        '12',
        calendarKind: UnifiedFieldsCalendarKind.jalali,
      ),
      '۱۲',
    );
    expect(
      UnifiedFieldsTypography.instance.localizeDigits(
        '12',
        calendarKind: UnifiedFieldsCalendarKind.gregorian,
      ),
      '12',
    );

    UnifiedFieldsTypography.instance = const UnifiedFieldsTypography(
      usePersianDigitsGlobally: true,
    );
    expect(UnifiedFieldsTypography.instance.localizeDigits('99'), '۹۹');
  });
}
