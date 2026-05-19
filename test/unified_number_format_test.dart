import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  tearDown(() {
    UnifiedFieldsTypography.instance = const UnifiedFieldsTypography();
  });

  test('formatUnifiedNumberFieldText localizes when global Persian digits', () {
    UnifiedFieldsTypography.instance = const UnifiedFieldsTypography(
      usePersianDigitsGlobally: true,
    );
    expect(
      formatUnifiedNumberFieldText(42, allowDecimals: false),
      '۴۲',
    );
    expect(
      formatUnifiedNumberFieldText(3.5, allowDecimals: true, fractionDigits: 1),
      '۳.۵',
    );
  });

  test('formatUnifiedNumberFieldText stays ASCII without global flag', () {
    expect(
      formatUnifiedNumberFieldText(42, allowDecimals: false),
      '42',
    );
  });

  test('localizeUnifiedNumberDisplayText converts partial typing text', () {
    UnifiedFieldsTypography.instance = const UnifiedFieldsTypography(
      usePersianDigitsGlobally: true,
    );
    expect(
      localizeUnifiedNumberDisplayText('12.'),
      '۱۲.',
    );
  });
}
