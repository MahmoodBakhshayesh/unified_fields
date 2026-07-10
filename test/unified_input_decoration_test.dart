import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/src/fields/unified_input_decoration.dart';

void main() {
  group('UnifiedInputDecoration.rowLabelRatio', () {
    test('merge keeps custom ratio when overlay layer is unset', () {
      const field = UnifiedInputDecoration(rowLabelRatio: [3, 3]);
      const overlay = UnifiedInputDecoration(
        borderSide: BorderSide(color: Color(0xFF00FF00)),
        height: 36,
      );

      final merged = field.merge(overlay);

      expect(merged.rowLabelRatio, [3, 3]);
    });

    test('effectiveRowLabelRatio falls back to default when unset', () {
      const decoration = UnifiedInputDecoration();

      expect(decoration.rowLabelRatio, isEmpty);
      expect(decoration.effectiveRowLabelRatio, UnifiedInputDecoration.defaultRowLabelRatio);
    });

    test('merge prefers explicit overlay ratio when provided', () {
      const field = UnifiedInputDecoration(rowLabelRatio: [3, 3]);
      const overlay = UnifiedInputDecoration(rowLabelRatio: [1, 4]);

      final merged = field.merge(overlay);

      expect(merged.rowLabelRatio, [1, 4]);
    });
  });
}
