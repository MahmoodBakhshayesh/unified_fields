import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  group('resolveUnifiedFieldLabelMode', () {
    test('explicit mode wins', () {
      expect(
        resolveUnifiedFieldLabelMode(
          mode: UnifiedFieldLabelMode.floatingLabel,
          labelInRow: true,
          themeMode: UnifiedFieldLabelMode.labelInColumn,
        ),
        UnifiedFieldLabelMode.floatingLabel,
      );
    });

    test('field labelInRow wins over theme column', () {
      expect(
        resolveUnifiedFieldLabelMode(
          labelInRow: true,
          themeMode: UnifiedFieldLabelMode.labelInColumn,
        ),
        UnifiedFieldLabelMode.labelInRow,
      );
    });

    test('theme is used when field does not request row', () {
      expect(
        resolveUnifiedFieldLabelMode(
          themeMode: UnifiedFieldLabelMode.labelInColumn,
        ),
        UnifiedFieldLabelMode.labelInColumn,
      );
    });

    test('falls back to floating when nothing is set', () {
      expect(resolveUnifiedFieldLabelMode(), UnifiedFieldLabelMode.floatingLabel);
    });
  });
}
