import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/src/fields/unified_input_decoration.dart';
import 'package:unified_fields/src/fields/unified_input_theme.dart';

void main() {
  group('UnifiedInputDecorationSet.resolve layout lock', () {
    testWidgets('readOnly overlay cannot override field height', (tester) async {
      await tester.pumpWidget(
        const UnifiedInputThemeScope(
          data: UnifiedInputThemeData(),
          child: SizedBox(),
        ),
      );
      final context = tester.element(find.byType(SizedBox));

      const set = UnifiedInputDecorationSet(
        base: UnifiedInputDecoration(height: 122),
        readOnly: UnifiedInputDecoration(height: 56),
      );

      final resolved = set.resolve(
        context,
        state: UnifiedInputFieldVisualState.readOnly,
        fieldDecoration: const UnifiedInputDecoration(height: 122),
      );

      expect(resolved.height, 122);
    });

    test('merge deep-merges layer decorations', () {
      const a = UnifiedInputDecorationSet(
        base: UnifiedInputDecoration(height: 80, label: 'A'),
      );
      const b = UnifiedInputDecorationSet(
        base: UnifiedInputDecoration(
          borderSide: BorderSide(color: Color(0xFF00FF00)),
        ),
      );

      final merged = a.merge(b);

      expect(merged.base?.height, 80);
      expect(merged.base?.borderSide?.color, const Color(0xFF00FF00));
    });
  });

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
