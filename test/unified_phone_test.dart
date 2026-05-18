import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  test('matchDialCode picks longest prefix', () {
    const pool = [UnifiedCountry.us, UnifiedCountry.ca, UnifiedCountry.ir];
    expect(
      UnifiedCountries.matchDialCode('+989121234567', pool)?.isoCode,
      'IR',
    );
    expect(
      UnifiedCountries.matchDialCode('+15551234567', pool)?.dialCode,
      '+1',
    );
  });

  test('applyUnifiedPhoneMask formats digits', () {
    expect(
      applyUnifiedPhoneMask('9121234567', '### ### ####'),
      '912 123 4567',
    );
  });

  test('isoToFlagEmoji', () {
    expect(isoToFlagEmoji('US').runes.length, greaterThanOrEqualTo(2));
  });

  test('India flag asset stem', () {
    expect(resolveUnifiedFlagAssetStem('IN'), 'c_in');
    expect(unifiedFlagAssetPath('IN'), 'assets/flags/countries/country_c_in.svg');
  });

  test('formatUnifiedFullPhoneText masks national digits', () {
    expect(
      formatUnifiedFullPhoneText(
        '989121234567',
        nationalMask: '### ### ####',
        countries: [UnifiedCountry.ir],
      ),
      '+98 912 123 4567',
    );
  });

  test('unifiedPhoneDigitsOnly accepts Persian digits', () {
    expect(unifiedPhoneDigitsOnly('۹۱۲۱۲۳۴۵۶۷'), '9121234567');
  });

  test('formatUnifiedFullPhoneText localizes with usePersianDigits', () {
    expect(
      formatUnifiedFullPhoneText(
        '989121234567',
        nationalMask: '### ### ####',
        countries: [UnifiedCountry.ir],
        usePersianDigits: true,
      ),
      '+۹۸ ۹۱۲ ۱۲۳ ۴۵۶۷',
    );
  });

  test('formatUnifiedFullPhoneText localizes unmatched dial prefix', () {
    expect(
      formatUnifiedFullPhoneText(
        '9',
        nationalMask: '### ### ####',
        countries: [UnifiedCountry.ir],
        usePersianDigits: true,
      ),
      '+۹',
    );
  });

  test('UnifiedCountry.localizedDialCode', () {
    expect(
      UnifiedCountry.ir.localizedDialCode(usePersianDigits: true),
      '+۹۸',
    );
  });

  test('UnifiedCountries.byIso', () {
    expect(UnifiedCountries.byIso('ir'), UnifiedCountry.ir);
    expect(UnifiedCountries.byIso('xx'), isNull);
  });

  test('matchDialCode accepts Persian digits in prefix', () {
    expect(
      UnifiedCountries.matchDialCode('+۹۸۹۱۲', [UnifiedCountry.ir])?.isoCode,
      'IR',
    );
  });
}
